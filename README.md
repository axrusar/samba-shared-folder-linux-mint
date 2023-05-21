# samba-shared-folder-linux-mint
Setup a network shared folder on linux Mint with SAMBA.

This script will setup a shared folder on the network accessible to other linux, windows or Mac clients using the SAMBA protocol.
The script will walk you through the steps and show you important information once it finished setting up.
The script should work on Linux mint 20.X and 21.X, XFCE, Mate and Cinnamon. It will most likely also work in other Ubuntu based distributions, i just havent tested it yet.


<h2>How to run the script</h2>
Steps for the absolute newbie: 

1. Download the latest version .sh file from this website.
2. Right click the downloaded file, open Properties, click the Permissions tab and tick the "Allow this file to run as a program" checkbox. Close the properties dialog.
3. Right click anywhere on an empty space next to the file, and chose "Open in terminal". A new terminal will open in the directory where the .sh file is located. For example ~/Downloads 
4. Now run the script. Type:
./setup-samba-shared-MEDIA.sh and hit enter. (replace the name of the file if different)
5. Follow the instructions during setup. DO not rush and pay attention to the prompts.

<h2>Installation</h2>
There are 2 initial modes during setup.
the first one (1) is the server setup, so the shared folder is created in the local machine.
the second one (2), is the client setup, so you are setting up this computer to connect to the remote folder you first setup in the server.
