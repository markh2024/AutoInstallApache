#!/bin/bash

rm -Rf /home/$USER/public_html
sudo systemctl stop  apache2
sudo apt remove apache2 -y
sudo rm -Rf /etc/apache2 /var/www/
sudo apt purge apache2 -y


