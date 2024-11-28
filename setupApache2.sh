#!/bin/bash

:'
 
 Script that will auto install all  required to get apache2 up and running easily on Debian 12 systems 
Targeting operating systems : 
PRETTY_NAME="Debian GNU/Linux 12 (bookworm)"
NAME="Debian GNU/Linux"
VERSION_ID="12"
VERSION="12 (bookworm)"
VERSION_CODENAME=bookworm
ID=debian
HOME_URL="https://www.debian.org/"
SUPPORT_URL="https://www.debian.org/support"
BUG_REPORT_URL="https://bugs.debian.org/"
 
'
:'
 
Link  for full explanation on git hub plus code at this 
address  below
https://github.com/markh2024/AutoInstallApache/tree/main 
 
To fetch pages  from  your own home area defined as public_html 
you use  http://localhost/~yourlogon name 
 
To pull up the main site with all help pages Apache manual  you use 
http://localhost/ the click the link marked manual 
 
Or you can use http://localhost/manual
 
'



# Adjust for your system's actual location of cowsay
COWSAY_PATH="/usr/games/cowsay"  # Adjust this if necessary

# Function to prompt user for confirmation
prompt_user() {
  while true; do
    echo -n "$1 (Y/N): "
    read -r response
    if [[ "$response" =~ ^[Yy]$ ]]; then
      return 0
    elif [[ "$response" =~ ^[Nn]$ ]]; then
      echo "Exiting script."
      exit 0
    else
      echo "Incorrect input. Please only enter 'y' or 'n'."
    fi
  done
}


# Function to display text with cowsay, accepts text as an argument
cowsay_text() {
  clear 
   
  if [ -x "$COWSAY_PATH" ]; then
    "$COWSAY_PATH" "$1"
  else
    echo "cowsay is not installed or not in the correct path."
  fi
  sleep 8
  clear 
}

# Ensure script is run with sudo privileges
if [ "$(id -u)" -ne 0 ]; then
  echo "Please run this script as root or with sudo."
  exit 1
fi

# Get the current user and group
USER=$(logname)
GROUP=$(id -gn)

# Get the current date and time
current_datetime=$(date +"%Y-%m-%d %H:%M:%S")

cowsay_text "My Install script for Apache2 MD Harrington London DA6 8NP : $current_datetime" 

# Function to execute a command and check its success
execute_and_check() {
  "$@"
  if [ $? -ne 0 ]; then
    echo "Error: Command failed -> $@"
    exit 1
  fi
}

# Step 1: Update system packages
prompt_user "Update package list and upgrade installed packages?"
execute_and_check sudo apt update
execute_and_check sudo apt upgrade -y

# Step 2: Install required tools
prompt_user "Install gnome-system-tools?"
execute_and_check sudo apt install gnome-system-tools -y

# Step 3: Install Apache2 web server
prompt_user "Install Apache2?"
execute_and_check sudo apt install apache2 -y

# Step 4: Start Apache2 service
prompt_user "Start Apache2?"
execute_and_check sudo systemctl start apache2

# Step 5: Check if Apache is running on localhost
prompt_user "Check Apache2 status?"
echo "Checking Apache2 status..."
execute_and_check systemctl status apache2

# Step 6: Create public_html directory in home area
prompt_user "Create public_html directory in /home/$USER?"
execute_and_check mkdir -p "/home/$USER/public_html"

# Step 7: Set ownership for public_html directory
prompt_user "Set ownership for /home/$USER/public_html to $USER:$GROUP?"
execute_and_check sudo chown -R "$USER:$GROUP" "/home/$USER/public_html"

# Step 8: Add Directory block for /home/$USER/public_html
prompt_user "Add Directory block for /home/$USER/public_html in 000-default.conf?"
echo "Adding Directory block for /home/$USER/public_html in 000-default.conf..."
sudo sed -i "/<\/VirtualHost>/i \
<Directory /home/$USER/public_html/>\n\
    Options Indexes FollowSymLinks\n\
    AllowOverride None\n\
    Require all granted\n\
</Directory>" /etc/apache2/sites-available/000-default.conf


# Step 9: Backup and modify userdir.conf
prompt_user "Edit userdir.conf to allow user directories?"
execute_and_check sudo cp /etc/apache2/mods-available/userdir.conf /etc/apache2/mods-available/userdir.conf.bck
sudo bash -c 'cat <<EOF > /etc/apache2/mods-available/userdir.conf
<IfModule mod_userdir.c>
    UserDir public_html
    <Directory /home/*/public_html>
        AllowOverride FileInfo AuthConfig Limit
        Options MultiViews Indexes SymLinksIfOwnerMatch IncludesNoExec
        Require method GET POST OPTIONS
    </Directory>
</IfModule>
EOF'

# Step 10: Enable userdir module
prompt_user "Enable userdir module?"
execute_and_check sudo a2enmod userdir

# Step 11: Restart Apache2 to apply changes
prompt_user "Restart Apache2 to apply changes?"
execute_and_check sudo systemctl restart apache2

# Step 12: Add www-data user to the $USER group
prompt_user "Add www-data user to the $USER group?"
execute_and_check sudo usermod -aG "$USER" www-data

# Step 13: Reset directory permissions
prompt_user "Reset directory permissions for /home/$USER and /home/$USER/public_html?"
execute_and_check sudo chmod 750 "/home/$USER"
execute_and_check sudo chmod 750 "/home/$USER/public_html"
execute_and_check sudo chown -R "$USER:$USER" "/home/$USER"

# Step 14: Place index.html in public_html folder
prompt_user "Place index.html file in public_html folder?"
cat > "/home/$USER/public_html/index.html" <<EOF
<html>
  <head>
    <title>Hello $USER</title>
  </head>
  <body>
    <div id="whatever">
      <p>Hello page and script written by no less than MD Harrington, and welcome to my page.</p>
    </div>
  </body>
</html>
EOF

# Step 15: Install ACL and set execute permission for www-data
prompt_user "Install ACL and set execute permission for www-data?"
execute_and_check sudo apt install acl -y
execute_and_check sudo setfacl -m u:www-data:x "/home/$USER"

# Step 16: Install Apache documentation
prompt_user "Install Apache documentation?"
execute_and_check sudo apt update
execute_and_check sudo apt install apache2-doc -y
execute_and_check sudo a2enmod alias

# Check if apache2-doc.conf exists and create it if missing 
# For some reason installs  fail  but this ensures all is there 
if [ ! -f "/etc/apache2/conf-available/apache2-doc.conf" ]; then
  echo "apache2-doc.conf not found. Creating it now..."
  cat > /etc/apache2/conf-available/apache2-doc.conf <<EOF
Alias /manual "/usr/share/doc/apache2-doc/manual"

<Directory "/usr/share/doc/apache2-doc/manual">
    Options Indexes MultiViews
    AllowOverride None
    Require all granted
</Directory>
EOF
  echo "apache2-doc.conf created successfully."
else
  echo "apache2-doc.conf already exists."
fi

# Enable the apache2-doc configuration
execute_and_check sudo a2enconf apache2-doc

# Restart Apache to apply changes
execute_and_check sudo systemctl restart apache2


#step 17 

# Step 17: Launch web browser to display pages

  echo "Please open the following URLs manually: to test your install "
  echo "1. http://localhost"
  echo
  echo "2. http://localhost/~$USER" 
  echo
  echo "3. http://localhost/manual"
  echo
  echo "Sleeping for 20 seconds whilst you check links above Nearly finished  just about there now " 
  sleep 30
  



echo "Apache setup and testing completed successfully!"

# Get the current date and time
current_datetime=$(date +"%Y-%m-%d %H:%M:%S")

# Call cowsay with the message and current date/time
cowsay_text "Thank you for watching MD Harrington London Kent DA6 8NP : $current_datetime"
