#!/bin/bash

# Function to stop Apache2 and uninstall phpMyAdmin
uninstall_phpmyadmin() {
    echo "Stopping the Apache2 web server..."
    sudo systemctl stop apache2
    if [ $? -eq 0 ]; then
        echo "Apache2 stopped successfully."
    else
        echo "Failed to stop Apache2. Please check your server configuration." >&2
        return 1
    fi

    echo "Uninstalling phpMyAdmin..."
    sudo apt-get purge -y phpmyadmin
    if [ $? -eq 0 ]; then
        echo "phpMyAdmin uninstalled successfully."
    else
        echo "Failed to uninstall phpMyAdmin. Please check for errors." >&2
        return 1
    fi

    echo "Removing residual files..."
    sudo apt-get autoremove -y
    sudo apt-get autoclean -y
    sudo rm -rf /usr/share/phpmyadmin
    sudo rm -rf /etc/phpmyadmin

    echo "Checking and removing phpMyAdmin directory in user's public_html..."
    PHP_MYADMIN_DIR="$HOME/public_html/phpmyadmin"
    if [ -d "$PHP_MYADMIN_DIR" ]; then
        sudo rm -rf "$PHP_MYADMIN_DIR"
        if [ $? -eq 0 ]; then
            echo "$PHP_MYADMIN_DIR directory removed successfully."
        else
            echo "Failed to remove $PHP_MYADMIN_DIR. Please check permissions." >&2
            return 1
        fi
    else
        echo "$PHP_MYADMIN_DIR directory does not exist. Skipping..."
    fi

    echo "phpMyAdmin and all related files have been removed."
}

# Call the function (optional)
# uninstall_phpmyadmin
