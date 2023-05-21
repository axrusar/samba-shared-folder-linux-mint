#!/bin/bash


#### Function to setup the shared folder as guest on the server
samba_server_guest() {
sudo apt-get update
# Check if Samba is installed
if ! dpkg -s samba > /dev/null 2>&1 ; then
  # Install Samba if it's not already installed
  echo "Samba is not installed. Installing..."
  
  sudo apt install samba -y
else
  echo "Samba is already installed."
fi

# install wsdd
sudo apt install wsdd -y

# install avahi for macOS clients
sudo apt install avahi-daemon -y

# Install the gvfs-backends
sudo apt install gvfs-backends -y

echo "Setting up SAMBA shared folder..."
echo "Current user: $USER"

#Allow samba in the firewall
sudo ufw allow samba


# Prompt user for share name
clear

while true; do
    echo ""  
    read -p "Please type a name for the new shared folder: " SHARENAME



  # Show preview of selected options
    echo ""  
    echo -e "Share name: \e[32m$SHARENAME\e[0m"
  echo -e "Shared folder location will be: \e[32m/media/$SHARENAME\e[0m"
  read -p "Is this correct? (Y/N): " confirm

  # If user confirms, exit the loop and continue with setup
  if [ "$confirm" = "Y" ] || [ "$confirm" = "y" ]; then
    break
  fi
done

# Create directory for shared folder
sudo mkdir -p "/media/$SHARENAME"
sudo chmod 777 /media/$SHARENAME

# Add configuration to smb.conf file
sudo tee -a /etc/samba/smb.conf > /dev/null <<EOT

# The following share was created by the setup samba shared folder script.
[$SHARENAME]
path = /media/$SHARENAME
read only = no
force user = $USER
guest ok = yes
EOT

# Restart the SAMBA service
sudo systemctl restart smbd
clear
echo ""
echo -e "Shared folder '\e[32m$SHARENAME\e[0m' has been set up successfully at \e[32m/media/$SHARENAME\e[0m"


## Get the IP address of the local machine (option replaced by hostname)
## IPADDR=$(hostname -I | awk '{print $1}')

# Display instructions for accessing the shared folder
echo ""
echo "To access the shared folder from other machines on the network:"
echo ""
echo "Linux clients:"
echo "1. Open the file manager."
echo -e "2. Enter the following URL in the address bar: \e[32msmb://$HOSTNAME.local/$SHARENAME\e[0m"
echo "3. Click 'Connect' and enter 'anonymous' as the username (no password needed)."
echo "If you want to set up the shared folder PERMANENTLY on your client,  "
echo "leave this window open, run this script on your client machine and select"
echo "the 'Setup this computer as the client' option from the menu"
echo -e "RED ADDRESS (for client setup): \e[31m//$HOSTNAME.local/$SHARENAME\e[0m"
echo ""
echo "Windows clients:"
echo "1. Open File Explorer."
echo "2. Click on 'This PC' on the left sidebar."
echo "3. Click on the computer tab and then choose 'Map network drive' in the top bar."
echo -e "4. Enter the following URL in the 'Folder' field: \e[32m\\\\\\\\$HOSTNAME\\\\$SHARENAME\e[0m"
echo "5. Click 'Finish' and enter 'guest' as the username (no password needed)."
echo ""

read -p "Press Enter to exit this program"
exit

}

#### End function to setup the shared folder as guest on the server

#### Function to setup the shared folder with password on the server
samba_server_passw() {
sudo apt-get update
# Check if Samba is installed
if ! dpkg -s samba > /dev/null 2>&1 ; then
  # Install Samba if it's not already installed
  echo "Samba is not installed. Installing..."
  
  sudo apt install samba -y
else
  echo "Samba is already installed."
fi

# install wsdd
sudo apt install wsdd -y

# install avahi for macOS clients
sudo apt install avahi-daemon -y


echo "Setting up SAMBA shared folder..."
echo "Current user: $USER"

#Allow samba in the firewall
sudo ufw allow samba

clear

# Prompt user for share name
while true; do
    echo ""  
    read -p "Please type a name for the new shared folder: " SHARENAME


  # Show preview of selected options
    echo ""  
    echo -e "Share name: \e[32m$SHARENAME\e[0m"
  echo -e "Shared folder location will be: \e[32m/media/$SHARENAME\e[0m"
  read -p "Is this correct? (Y/N): " confirm

  # If user confirms, exit the loop and continue with setup
  if [ "$confirm" = "Y" ] || [ "$confirm" = "y" ]; then
    break
  fi
done

# Create directory for shared folder
sudo mkdir -p "/media/$SHARENAME"
sudo chmod 777 /media/$SHARENAME



## Password setup
# Get the current user's name
#samba_username=$USER

# Prompt user to enter a samba username
read -p "Enter the username for the shared folder: " samba_username

# Prompt user to enter a password
read -s -p "Enter the password for the shared folder: " password
echo ""

# Set up the shared folder with the password
echo -e "Setting up shared folder with password..."

sudo adduser --no-create-home --disabled-password --disabled-login --gecos "" "$samba_username"

echo -e "$password\n$password" | sudo smbpasswd -a -s "$samba_username"
echo -e "Shared folder was succesfully set with password: " $password
    
# Add configuration to smb.conf file
sudo tee -a /etc/samba/smb.conf > /dev/null <<EOT

# The following share was created by the setup samba shared folder script.
[$SHARENAME]
path = /media/$SHARENAME
read only = no
force user = $samba_username
valid users = $samba_username
guest ok = no
EOT

# Restart the SAMBA service
sudo systemctl restart smbd

echo -e "Shared folder '\e[32m$SHARENAME\e[0m' has been set up successfully at \e[32m/media/$SHARENAME\e[0m"

## Get the IP address of the local machine (option replaced by hostname)
## IPADDR=$(hostname -I | awk '{print $1}')

# Display instructions for accessing the shared folder
clear
echo ""
echo "To access the shared folder from other machines on the network:"
echo ""
echo "Linux clients:"
echo "1. Open the file manager."
echo -e "2. Enter this address: \e[32msmb://$HOSTNAME.local/$SHARENAME\e[0m"
echo "3. Connect as 'Registered User'"
echo -e "Username: \e[32m$samba_username\e[0m, Domain: '\e[32mworkgroup\e[0m', password: \e[32m$password\e[0m"
echo "If you want to set up the shared folder PERMANENTLY on your client,  "
echo "DO NOT CLOSE THIS WINDOW, run this script on your client machine"
echo -e "RED ADDRESS (for client setup): \e[31m//$HOSTNAME.local/$SHARENAME\e[0m"
echo ""
echo "Windows clients:"
echo "1. Open File Explorer."
echo "2. Click on 'This PC' on the left sidebar."
echo "3. Click on the computer tab and then choose 'Map network drive' in the top bar."
echo -e "4. Enter this URL in the folder field: \e[32m\\\\\\\\$HOSTNAME\\\\$SHARENAME\e[0m"
echo "5. Tick the 'Connect using different credentials' checkbox"
echo -e "Username: \e[32m$samba_username\e[0m, password: \e[32m$password\e[0m"
echo "6. Remember my credentials and click 'OK'."



read -p "Press Enter to exit this program"
exit
}

#### End Function to setup the shared folder with password on the server



#### Function to setup the client with a CIFS mount

cifs_setup() {

# Prompt the user for a directory name
read -p "Enter the name of the shared directory: " dir_name

# Create the directory and set full access for the current user
sudo mkdir -p "/media/$dir_name"
sudo chmod 777 "/media/$dir_name"
sudo chown -R $USER:$USER "/media/$dir_name"

# Prompt the user for the network share path

while true; do
    read -p "Enter the path of the shared folder on the server EXACTLY AS DISPLAYED IN RED during setup (e.g. //hostname/ShareName): " share_path
    if [[ $share_path =~ ^\/\/[a-zA-Z0-9_.-]+\/[a-zA-Z0-9_]+ ]]; then
        break
    else
        echo "Invalid format. Please enter the path in the format //hostname/ShareName"
    fi
done


# Add the CIFS mount to /etc/fstab
echo "${share_path} /media/$dir_name cifs credentials=/etc/samba/.smbcredentials,uid=$UID,nounix,noauto,user,dir_mode=0777,file_mode=0666 0 0" | sudo tee -a /etc/fstab > /dev/null

# Prompt the user for the username and password to access the network share
read -p "Enter the username to access the network share (hit ENTER if no username was set): " username
read -s -p "Enter the password to access the network share (hit ENTER if no password was set): " password

# Create the .smbcredentials file with the username and password
echo "username=$username" | sudo tee /etc/samba/.smbcredentials > /dev/null
echo "password=$password" | sudo tee -a /etc/samba/.smbcredentials > /dev/null
sudo chmod 600 /etc/samba/.smbcredentials

# Install the gvfs-backends
sudo apt install gvfs-backends -y


# Mount the share
sudo mount -a
echo ""
read -p "Press Enter to exit this program"
exit

}

#### END Function to setup the client with a CIFS mount



#### Main section with the setup menu

# Function to display the main menu
show_menu() {
    clear
    echo -e "\e[1;36mSelect an option:\e[0m"
    echo -e "\e[1;34m1. Share a folder from this computer (server)\e[0m"
    echo -e "\e[1;34m2. Connect this computer to a shared folder (client)\e[0m"
    echo -e "\e[1;31m0. Quit\e[0m"
}

# Function to display the server setup menu
show_server_menu() {
    clear
    echo -e "\e[1;36mSelect an option:\e[0m"
    # share guest menu option
    echo -e "\e[1;34m1. Setup the shared folder without a password\e[0m"
    # share pass menu option
    echo -e "\e[1;34m2. Setup the shared folder with a password\e[0m"
    echo -e "\e[1;31m0. Go back\e[0m"
}

# Function to execute shared folder without a password
share_guest() {
    clear
    echo -e "\e[1;34mSetting up...\e[0m"
    # Code for option 1b goes here
    samba_server_guest
}

# Function to execute shared folder with a password
share_pass() {
    clear
    echo -e "\e[1;34mSetting up...\e[0m"
    # Code for option 2b goes here
    samba_server_passw
}





# Function to execute option 1
option_1() {
    clear
    echo -e "\e[1;34mOption 1 selected\e[0m"
    while true; do
        show_server_menu
        read -p "Enter your choice: " choice
        case $choice in
            1) share_guest ;;
            2) share_pass ;;
            0) break ;;
            *) clear; echo -e "\e[1;31mInvalid option. Please try again.\e[0m" ;;
        esac
    done
}

# Function to execute option 2
option_2() {
    clear
    echo -e "\e[1;34mOption 2 selected\e[0m"
    cifs_setup
}

# Loop to display the main menu until user quits
while true; do
    show_menu
    read -p "Enter your choice: " choice
    case $choice in
        1) option_1 ;;
        2) option_2 ;;
        0) clear; exit 0 ;;
        *) clear; echo -e "\e[1;31mInvalid option. Please try again.\e[0m" ;;
    esac
done
