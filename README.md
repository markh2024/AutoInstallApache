# Script to auto Install  Apache2 

## Author of this document:
#### MD Harrington  Bexleyheath  Kent London UK

## Date of publication :
#### 27-11-2024 

## Version: 
Server version: Apache/2.4.62 (Debian)
Server built:   2024-10-04T15:21:08

## Targeting operating systems : 
PRETTY_NAME="Debian GNU/Linux 12 (bookworm)"<br>
NAME="Debian GNU/Linux"<br>
VERSION_ID="12"<br>
VERSION="12 (bookworm)"<br>
VERSION_CODENAME=bookworm<br>
ID=debian<br>
HOME_URL="https://www.debian.org/"<br>
SUPPORT_URL="https://www.debian.org/support"<br>
BUG_REPORT_URL="https://bugs.debian.org/"<br>

### Goal: 

To automatically install  apache 2 , modify scripts  without user having to edit each script or having to make back ups of each  before auto editing

#### All scripts are directly driven  via ApacheMenu.sh 
#### I will update this README.md  at some point tomorrow to reflect all changes 

### Important note 

Please ensure you chmod + x  all files  before attempting to use 


Creates a public_html folder in users home area  and auto writes and saves an index.html test file to that area 
Creates an index.html file in /var/www/html and public_html folder 
Creates a test.php  file in both /var/www/html and public_html folder to test  your php  install 

Sets all permissions  to access that area from local network 

### Here’s a summary of the operations performed by the script:

   *  Check for Root Privileges: Ensure the script is run as root or with  sudo. <br><br>

   *  Update System Packages: Update package list and upgrade installed packages.<<br><br>

   *  Install Tools: Install gnome-system-tools.<<br><br>
   *  Install Apache2: Install the Apache2 web server.<br><br>
   *  Start Apache2 Service: Start the Apache2 service.<br><br>
   *  Check Apache2 Configuration: Test Apache2 configuration for errors.<br><br>
   *  Create public_html Directory: Create the public_html directory in the user's home directory.<br><br>
   *  Set Ownership of public_html: Change the ownership of the public_html directory to the user.<br><br>
   *  Edit Apache Configuration (apache2.conf): Modify apache2.conf to allow access to public_html.<br><br>
   *  Modify 000-default.conf: Edit 000-default.conf to change the DocumentRoot and add directory block for public_html.<br><br>
   *  Edit userdir.conf: Modify userdir.conf to allow access to user directories.<br><br>
   *  Enable userdir Module: Enable the userdir Apache2 module.<br><br>
   *  Install Apache2 Documentation (apache2-doc): Install Apache2 documentation.<br><br>
   *  Enable apache2-doc.conf Configuration: Enable the apache2-doc configuration.<br><br>
   *  Enable Alias Module: Enable the Alias module in Apache2. <br><br>
   *  Restart Apache2 Service: Restart Apache2 to apply the new configurations.<br><br>
   *  Create index.html in public_html: Place a test index.html file in the user's public_html directory.<br><br>
   *  Install ACL and Set Permissions for www-data: Install ACL and grant execute permissions to the www-data user on public_html. <br><br>
   *  Final Apache2 Restart: Restart Apache2 for the final time to apply all changes. <br><br>
   *  Finally displays Completion Message: Indicating the Apache installation and configuration with user directories and documentation is complete.

This summary captures the key steps and their corresponding actions within the script.


## Extra Notes 

After downloading script  please  ensure you run the script through dos2unix 

To do this install dos2unix  command 

sudo apt update && sudo apt install dos2unix 

Chmod the file to  executable 

Command to do this from terminal is  chmod + x sriptname.sh 

##### Enjoy !! 
This makes you life 100X easier 
