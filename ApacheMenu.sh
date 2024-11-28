#!/bin/bash

# Display the menu title
echo "Installation of Apache2 MD Harrington London Kent DA6 8NP"
echo "----------------------------------------------------------"

# Function to display the menu and handle user choice
display_menu() {
  while true; do
    # Clear the screen
    clear

    # Display the menu options
    echo "1: Uninstall Apache2"
    echo "2: Install Apache2"
    echo "3: Install PHP"
    echo "4: Exit"
    echo -n "Enter your choice: "
    read choice

    case $choice in
      1)
        echo "You selected: Uninstall Apache2"
        if [ -x "./uninstallApache2.sh" ]; then
         sudo ./uninstallApache2.sh
        else
          echo "Error: uninstallApache2.sh not found or not executable."
        fi
        ;;
      2)
        echo "You selected: Install Apache2"
        if [ -x "./setupApache2.sh" ]; then
         sudo ./setupApache2.sh
        else
          echo "Error: setupApache2.sh not found or not executable."
        fi
        ;;
      3)
        echo "You selected: Install PHP"
        if [ -x "./phpinstall.sh" ]; then
         sudo ./phpinstall.sh
        else
          echo "Error: phpinstall.sh not found or not executable."
        fi
        ;;
      4)
        echo "Exiting the menu."
        exit 0
        ;;
      *)
        echo "Invalid choice, please enter a number between 1 and 4."
        sleep 3  # Wait for 3 seconds before displaying the menu again
        ;;
    esac
  done
}

# Run the menu function
display_menu
