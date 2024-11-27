#!/bin/bash

# Global variable for pause time (in seconds)
PAUSE_TIME=3  # Change this value to set the pause duration

# Function to clear screen, display text, wait for a time period, and then clear screen again
prompt_and_pause() {
	
   Additional=" The screen will clear in $PAUSE_TIME seconds. Please wait for all to complete ... " 
  # Prompt the user with the message
  echo "$1 $Additional "
  echo 

  # Pause for the specified time period (global PAUSE_TIME variable)
  sleep "$PAUSE_TIME"

  # Clear the screen again
  clear
}


# Function to prompt user for confirmation
prompt_user() {
  while true; do  # Keep looping until valid input is received
    echo -n "$1 (Y/N): "
    read -r response
    # Check if the response is 'y' or 'n'
    if [[ "$response" =~ ^[Yy]$ ]]; then
      return 0  # Valid 'y' response
    elif [[ "$response" =~ ^[Nn]$ ]]; then
      echo "Exiting script."
      exit 0  # Valid 'n' response, exit the script
    else
      # If the response is invalid, ask again
      echo "Incorrect input. Please only enter 'y' or 'n'."
    fi
  done
}

# Ensure script is run with sudo privileges
if [ "$(id -u)" -ne 0 ]; then
  echo "Please run this script as root or with sudo."
  exit 1
fi

# Get the original user and group (handles sudo correctly)
USER=$(logname)
GROUP=$(id -gn "$USER")

# Step 1: Update system packages
prompt_user "Update package list and upgrade installed packages?"
echo "Updating package list and upgrading installed packages..."
apt update && apt upgrade -y

# Step 2: Install required tools
prompt_user "Install gnome-system-tools?"
echo "Installing gnome-system-tools..."
apt install gnome-system-tools -y

# Step 3: Install Apache2 web server
prompt_user "Install Apache2?"
echo "Installing Apache2..."
apt install apache2 -y

# Step 4: Start Apache2 service
prompt_user "Start Apache2?"
echo "Starting Apache2..."
systemctl start apache2

# Step 5: Check Apache2 configuration before proceeding
echo "Testing Apache2 configuration..."
apachectl configtest || { echo "Apache2 configuration has errors. Exiting."; exit 1; }

# Step 6: Create public_html directory in home area
prompt_user "Create public_html directory in /home/$USER?"
echo "Creating public_html directory in /home/$USER..."
mkdir -p "/home/$USER/public_html"

# Step 7: Set ownership for public_html directory
prompt_and_pause "Setting ownership for /home/$USER/public_html to $USER:$GROUP"
chown -R "$USER:$GROUP" "/home/$USER/public_html"

# Step 8: Backup and modify apache2.conf to allow user directories
prompt_and_pause "Editing apache2.conf to allow access to /home/$USER/public_html?"
cp /etc/apache2/apache2.conf /etc/apache2/apache2.conf.bck
sed -i "/<\/Directory>/a \
<Directory /home/$USER/public_html>\n\
Options Indexes FollowSymLinks\n\
AllowOverride None\n\
Require all granted\n\
</Directory>" /etc/apache2/apache2.conf

# Step 9: Backup and modify 000-default.conf
prompt_and_pause "Editting 000-default.conf to change DocumentRoot and add Directory block within <VirtualHost>"
cp /etc/apache2/sites-available/000-default.conf /etc/apache2/sites-available/000-default.conf.bck

# Insert Directory block within <VirtualHost> before </VirtualHost>
sed -i "/<\/VirtualHost>/i \
<Directory /home/$USER/public_html/>\n\
    Options Indexes FollowSymLinks\n\
    AllowOverride None\n\
    Require all granted\n\
</Directory>" /etc/apache2/sites-available/000-default.conf

# Step 10: Modify userdir.conf to allow user directories
prompt_and_pause "Editing userdir.conf to allow user directories?"
cp /etc/apache2/mods-available/userdir.conf /etc/apache2/mods-available/userdir.conf.bck
cat > /etc/apache2/mods-available/userdir.conf << EOF
<IfModule mod_userdir.c>
    UserDir public_html
    <Directory /home/*/public_html>
        AllowOverride FileInfo AuthConfig Limit
        Options MultiViews Indexes SymLinksIfOwnerMatch IncludesNoExec
        Require method GET POST OPTIONS
    </Directory>
</IfModule>
EOF

# Step 11: Enable userdir module
prompt_and_pause"Enabling userdir module..."
a2enmod userdir

# ** NEW STEPS ADDED **

# Step 12: Install Apache2 Documentation (apache2-doc)
prompt_user "Install Apache2 Documentation?"
echo "Installing Apache2 Documentation..."
apt install apache2-doc -y

# Step 13: Enable the apache2-doc.conf configuration
echo "Checking if apache2-doc.conf exists..."
if [ ! -f /etc/apache2/conf-available/apache2-doc.conf ]; then
    echo "apache2-doc.conf does not exist. Exiting."
    exit 1
fi

prompt_and_pause "Enabling apache2-doc configuration..."
a2enconf apache2-doc

# Step 14: Enable Alias module
prompt_and_pause "Enabling Alias module..."
a2enmod alias

# Step 15: Restart Apache2 to apply changes
prompt_and_pause "Restarting Apache2..."
systemctl restart apache2

# ** END OF NEW STEPS **

# Step 16: Add index.html to public_html
prompt_user "Place test index.html file in /home/$USER/public_html?"
cat > "/home/$USER/public_html/index.html" << EOF
<html>
  <head>
    <title>Hello $USER</title>
  </head>
  <body>
    <div id="whatever">
    <p>Hello page and script written by no less than MD Harrington
     , and welcome to my page.</p>
    </div>
  </body>
</html>
EOF

# Step 17: Install ACL and add execute permissions for www-data
prompt_and_pause "Installing ACL and set execute permissions for www-data on /home/$USER?"
echo "Installing ACL..."
apt install acl -y
setfacl -m u:www-data:x "/home/$USER"

# Step 18: Final restart of Apache2
prompt_and_pause "Restart Apache2 to apply changes?"
echo "Restarting Apache2..."
systemctl restart apache2

echo "Apache installation and configuration with user directories and documentation completed successfully!"
