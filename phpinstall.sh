#!/bin/bash

# Ensure the script is run with sudo privileges
if [ "$(id -u)" -ne 0 ]; then
  echo "Please run this script as root or with sudo."
  exit 1
fi

# Function to execute a command and check its success
execute_and_check() {
  "$@"
  if [ $? -ne 0 ]; then
    echo "Error: Command failed -> $@"
    exit 1
  fi
}

# Step 1: Uninstall existing PHP and Apache modules
echo "Removing existing PHP and Apache modules..."
execute_and_check apt remove --purge php libapache2-mod-php8.2 php8.2 php8.2-cli php8.2-common php8.2-opcache php8.2-readline -y
execute_and_check apt autoremove -y

# Step 2: Update package lists
echo "Updating package lists..."
execute_and_check apt update

# Step 3: Install Apache and PHP
echo "Installing Apache and PHP..."
execute_and_check apt install apache2 libapache2-mod-php php -y

# Step 4: Enable necessary Apache modules
echo "Enabling Apache modules..."
execute_and_check a2enmod php8.2
execute_and_check a2enmod userdir

# Step 5: Restart Apache to apply changes
echo "Restarting Apache..."
execute_and_check systemctl restart apache2

# Step 6: Verify PHP installation by creating a test file
echo "Creating PHP test file in the document root..."
echo "<?php phpinfo(); ?>" | sudo tee /var/www/html/test.php > /dev/null
chmod 644 /var/www/html/test.php

# Step 7: Configure PHP for user directories
echo "Configuring PHP for user directories..."
PHP_CONF="/etc/apache2/mods-enabled/php8.2.conf"
if [ -f "$PHP_CONF" ]; then
  sed -i 's/php_admin_flag engine Off/php_admin_flag engine On/' "$PHP_CONF"
  echo "Updated PHP configuration to enable PHP in user directories."
else
  echo "Error: PHP configuration file not found." >&2
  exit 1
fi

# Step 8: Restart Apache again
echo "Restarting Apache for user directory configuration..."
execute_and_check systemctl restart apache2

# Step 9: Create a PHP test file in the user's public_html directory
echo "Creating PHP test file in user's public_html..."
USER=$(logname)
USER_HOME=$(getent passwd "$USER" | cut -d: -f6)

mkdir -p "$USER_HOME/public_html"
echo "<?php phpinfo(); ?>" > "$USER_HOME/public_html/test.php"
chmod 755 "$USER_HOME/public_html"
chmod 644 "$USER_HOME/public_html/test.php"

# Step 10: Print test URLs to the user
echo "PHP test files have been created."
echo "You can test PHP at the following URLs: This will sleep for 30 seconds whilst you test links "
echo
echo "1. http://localhost/test.php (Document root)"
echo
echo "2. http://localhost/~$USER/test.php (User public_html)"
sleep 30
echo "PHP installation and configuration complete."
