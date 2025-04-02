NukeIT 

NukeIT is a PowerShell-based GUI application that allows users to quickly block or unblock multiple executable files from accessing the internet by creating Windows Firewall rules.
Features

    Block all .exe files in a selected folder and its subfolders from accessing the internet
    Create both inbound and outbound firewall rules for comprehensive protection
    Detect and report applications that are already blocked in the firewall
    Track blocked applications in a text file for easy management
    One-click removal of all created firewall rules
    Simple and intuitive graphical user interface

How It Works

The application creates Windows Firewall rules that block specific executable files from establishing network connections. It generates both inbound and outbound rules to ensure that the selected applications cannot communicate with the internet in any way.

NukeIT maintains a list of blocked applications in a file called "blocked_exes.txt" in the user's profile directory, which allows for easy removal of rules when they're no longer needed.
Use Cases

    Control which applications can access the internet
    Block potentially unwanted applications from communicating with remote servers
    Create temporary internet blocks for specific applications
    Enhanced security by restricting network access for applications you don't trust

Ideal for system administrators, privacy-conscious users, or anyone looking to gain more control over their system's network communications.


