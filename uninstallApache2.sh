#!/bin/bash

# Ensure script is run with sudo privileges
if [ "$(id -u)" -ne 0 ]; then
  echo "Please run this script as root or with sudo."
  exit 1
fi

# Stop Apache service
echo "Stopping Apache service..."
sudo systemctl stop apache2

# Remove PHP and Apache2
echo "Uninstalling Apache2 and PHP..."
sudo apt remove --purge apache2 php libapache2-mod-php -y
sudo apt autoremove -y
execute_and_check apt remove --purge php libapache2-mod-php8.2 php8.2 php8.2-cli php8.2-common php8.2-opcache php8.2-readline -y
execute_and_check apt autoremove -y

# Remove residual configuration files and directories
echo "Removing Apache and PHP configuration files and directories..."
sudo rm -rf /etc/apache2 /var/www /etc/php /var/lib/php /usr/lib/php /usr/share/php /etc/apache2/mods-available /etc/apache2/conf-available

# Check and remove any remaining directories if necessary
directories=(
  "/var/www/html"
  "/etc/apache2/mods-enabled"
  "/etc/apache2/conf-available"
)

for dir in "${directories[@]}"; do
  if [ -d "$dir" ]; then
    echo "Removing directory: $dir"
    sudo rm -rf "$dir"
  fi
done

# Remove user public_html folder
USER=$(logname)
if [ -d "/home/$USER/public_html" ]; then
  echo "Removing public_html folder for user $USER..."
  rm -rf "/home/$USER/public_html"
fi

# Confirm completion
echo "Apache2 and PHP have been successfully uninstalled."
