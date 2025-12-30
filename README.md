
![Logo](https://gmrs-link.com/images/link-scripting_50_1_50.png)   
![Release Version](https://img.shields.io/badge/Version-v1.5.0-blue?color=blue)
![OS Version](https://img.shields.io/badge/OS-Linux_*_Hamvoip-red?color=red)

# ReConn

This Script is designed to help with connection drops to keep you connected to the server.   
This Script is tailored for GMRS users from the GMRS Freedom Nation network.

## Prerequisites
     
- Must have G.F.N image version 1.5.0 or higher.

## Installation & Setup

1. SSH into the node and open a bash terminal. Then copy and paste the line below.

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/Justice57201/ReConn_other/main/ReConn_other_installer.sh)"
```
2. During the install, you will be prompted for.
    - Node number
    - DTMF numbers to enable & disable     

       
>[!NOTE]
>  
> I recommend.  
> - Enable 917  
> - Disable 918    


3. If the installation completed without errors, reboot the node.

## Setup

1. SSH into the node, on the admin menu, look for ReConn Setup & open it.

2. Enter your node number & the hub or node you want to stay connected to.

## Testing

1. Disconnect from any hubs or nodes.

2. Wait for it to ReConn to the hub you selected, every 10 min.

## How to use with the radio's DTMF

1. Key the radio and enter *917 on the keypad. Unkey, you should hear an audible notification indicating that "ReConn enabled."

2. Repeat with the disable code.

## How to use with Supermon

1. Log in to your supermon page.

2. Select the node # you configured & click the Control button.

3. Click the drop-down bar.

4. Now you can select to enable or disable ReConn.



## Author

- [WRQC343](https://www.gmrs-link.com)


