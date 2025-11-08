[![NukeIT.png](https://i.postimg.cc/FHy6n1ZM/NukeIT.png)]


# NukeIT Enhanced - Executable & Website Blocker

<div align="center">

![Version](https://img.shields.io/badge/version-2.0-blue.svg)
![PowerShell](https://img.shields.io/badge/PowerShell-5.1+-blue.svg)
![License](https://img.shields.io/badge/license-MIT-green.svg)
![Platform](https://img.shields.io/badge/platform-Windows-lightgrey.svg)

**A powerful Windows firewall and website blocking tool with GUI interface**

</div>

---

## 📋 Table of Contents
- [Overview](#-overview)
- [Features](#-features)
- [Requirements](#-requirements)
- [Installation](#-installation)
- [Usage](#-usage)
- [Changelog](#-changelog)
- [Building from Source](#-building-from-source)
- [How It Works](#-how-it-works)
- [Screenshots](#-screenshots)
- [FAQ](#-faq)
- [Contributing](#-contributing)
- [License](#-license)

---

## 🎯 Overview

NukeIT Enhanced is a Windows application that provides an easy-to-use interface for blocking executable files from accessing the internet and blocking websites through the Windows hosts file. Perfect for parental controls, productivity management, or security hardening.

---

## ✨ Features

### 🔒 Executable Blocking
- **Bulk Block**: Block all `.exe` files in a folder (including subfolders) from internet access
- **Firewall Integration**: Creates both inbound and outbound Windows Firewall rules
- **Smart Detection**: Automatically detects already-blocked applications
- **Easy Unblock**: Remove all blocks with a single click
- **View Blocked List**: See all currently blocked executables

### 🌐 Website Blocking
- **Hosts File Management**: Block websites by redirecting to localhost (127.0.0.1)
- **Multiple Formats Supported**: 
  - Domain names (facebook.com)
  - www variants (automatically handled)
  - IP addresses
  - URLs (automatically cleaned)
- **Individual or Bulk Unblock**: Remove one or all blocked websites
- **View Blocked List**: See all currently blocked websites

### ✅ Testing & Verification
- **Test Website Block**: Verify if a website is actually blocked
- **Detailed Status Report**: Shows:
  - Hosts file status
  - Tracking file status
  - DNS resolution results
- **Flush DNS Cache**: Clear DNS cache with one click
- **Real-time Verification**: Confirm blocks are working before testing in browser

### 💾 Tracking & Persistence
- **Automatic Tracking**: All blocks are logged to text files
- **Persistent Storage**: 
  - `blocked_exes.txt` - Stores blocked executables
  - `blocked_websites.txt` - Stores blocked websites
- **No Database Required**: Simple text file storage

---

## 💻 Requirements

- **OS**: Windows 10/11 (or Windows Server 2016+)
- **PowerShell**: Version 5.1 or higher
- **Privileges**: Administrator rights (required for firewall and hosts file modification)
- **.NET Framework**: 4.5 or higher (usually pre-installed)

---

## 📥 Installation

### Option 1: Download Pre-built EXE (Recommended)
1. Download `NukeIT.exe` from the [Releases](../../releases) page
2. Right-click the EXE → **Run as Administrator**
3. Start blocking!

### Option 2: Run PowerShell Script
1. Download `NukeIT.ps1`
2. Open PowerShell as Administrator
3. Navigate to the download folder
4. Run:
   ```powershell
   Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force
   .\NukeIT.ps1
   ```

---

## 🚀 Usage

### Blocking Executables
1. Click **Browse...** to select a folder containing executables
2. Click **NukeIT (Block)** to block all `.exe` files in that folder
3. Confirm the success message
4. Click **View Blocked** to see the list of blocked executables

### Blocking Websites
1. Enter a website in the text field (e.g., `facebook.com`)
2. Click **Block Website/IP**
3. The website will be blocked immediately
4. Click **View Blocked** to see all blocked websites

### Testing Blocks
1. Enter a website in the "Test Website" field
2. Click **Test Website Block**
3. View the detailed status report showing:
   - ✓ Hosts file status
   - ✓ Tracking file status
   - ✓ DNS resolution results

### Unblocking
- **Executables**: Click **Un-NukeIT** to remove all EXE blocks
- **Single Website**: Enter website and click **Unblock Website**
- **All Websites**: Click **Unblock ALL Websites**

---

## 📝 Changelog

### Version 2.0 (Latest)
**New Features:**
- ✨ Added website/IP blocking via Windows hosts file
- ✨ Added "View Blocked" buttons for both EXEs and websites
- ✨ Added comprehensive testing/verification system
- ✨ Added DNS cache flushing functionality
- ✨ Added detailed status reports for blocked websites
- 🎨 Enhanced UI with better organization and sections
- 📊 Added real-time verification of blocks

**Improvements:**
- 🔧 Better error handling with detailed messages
- 🔧 Automatic DNS cache clearing after blocks
- 🔧 Support for multiple website formats (URLs, www, etc.)
- 🔧 Duplicate prevention for both EXEs and websites
- 📝 Enhanced tracking file management

**Bug Fixes:**
- 🐛 Fixed tracking file initialization issues
- 🐛 Fixed DNS cache not updating immediately
- 🐛 Improved hosts file parsing

### Version 1.0
- Initial release
- Basic executable blocking functionality
- Firewall rule creation
- Simple GUI interface

---

## 🔨 Building from Source

### Converting to EXE

We provide a converter script to build the EXE from the PowerShell script:

1. Download `ConvertToEXE.ps1`
2. Place it in the same folder as `NukeIT.ps1`
3. Run PowerShell as Administrator
4. Execute:
   ```powershell
   Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force
   .\ConvertToEXE.ps1
   ```
5. Enter `NukeIT.ps1` when prompted
6. The EXE will be created in the same folder

**Converter Features:**
- Automatically installs PS2EXE module
- Creates standalone EXE with no dependencies
- Configures for Administrator privileges
- No console window (GUI only)

---

## ⚙️ How It Works

### Executable Blocking
NukeIT creates Windows Firewall rules that prevent specific executables from making network connections:
- **Outbound Rule**: Blocks the application from sending data to the internet
- **Inbound Rule**: Blocks the application from receiving data from the internet
- Both rules are set to `Block` action and enabled for all profiles (Domain, Private, Public)

### Website Blocking
NukeIT modifies the Windows hosts file (`C:\Windows\System32\drivers\etc\hosts`):
- Adds entries redirecting blocked domains to `127.0.0.1` (localhost)
- Blocks both `domain.com` and `www.domain.com` variants
- Flushes DNS cache to ensure immediate effect
- All entries are tagged with `# Blocked by NukeIT` for easy identification

### Verification System
The testing feature performs three checks:
1. **Hosts File Check**: Scans the hosts file for the domain
2. **Tracking File Check**: Verifies the domain is in the tracking list
3. **DNS Resolution**: Uses .NET DNS resolver to check what IP the domain resolves to

---

## 📸 Screenshots

```
┌─────────────────────────────────────────────┐
│  ===== BLOCK .EXE FILES =====              │
│  [Folder Path]              [Browse...]     │
│  [NukeIT] [Un-NukeIT] [View Blocked]       │
│                                             │
│  ===== BLOCK WEBSITES/IPs =====            │
│  [Website/IP]                              │
│  [Block] [Unblock] [View Blocked]          │
│  [Unblock ALL Websites]                    │
│                                             │
│  ===== TEST BLOCKING =====                 │
│  [Test Website]                            │
│  [Test Website Block] [Flush DNS Cache]    │
└─────────────────────────────────────────────┘
```

---

## ❓ FAQ

**Q: Do I need to run this as Administrator?**  
A: Yes, modifying firewall rules and the hosts file requires Administrator privileges.

**Q: Will this work on Windows 11?**  
A: Yes! NukeIT works on Windows 10, 11, and Server 2016+.

**Q: Can I block specific ports instead of entire executables?**  
A: Currently, NukeIT blocks all network access for selected executables. Port-specific blocking may be added in a future version.

**Q: Why isn't the website blocked in my browser?**  
A: Try clicking "Flush DNS Cache" after blocking. Browsers cache DNS results, so you may need to restart your browser.

**Q: Where are the tracking files stored?**  
A: In your user profile folder:
- `%USERPROFILE%\blocked_exes.txt`
- `%USERPROFILE%\blocked_websites.txt`

**Q: Can I edit the tracking files manually?**  
A: Yes, they're plain text files. However, you'll need to manually create/remove firewall rules and hosts entries to match.

**Q: Will this block VPN connections?**  
A: NukeIT can block VPN executables from running, but it won't block traffic going through an already-established VPN.

**Q: Is this antivirus software?**  
A: No, NukeIT is a blocking tool. It prevents applications and websites from being accessed but doesn't scan for malware.

---

## 🤝 Contributing

Contributions are welcome! Here's how you can help:

1. **Report Bugs**: Open an issue describing the problem
2. **Suggest Features**: Open an issue with your feature request
3. **Submit Pull Requests**: Fork, make changes, and submit a PR
4. **Improve Documentation**: Help make the README clearer

### Development Setup
1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## 📄 License

This project is licensed under the MIT License - see below for details:

```
MIT License

Copyright (c) 2025 NukeIT

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

---

## 🙏 Acknowledgments

- Built with PowerShell and Windows Forms
- Uses PS2EXE for executable conversion
- Inspired by the need for simple, effective application and website blocking

---

## 📞 Support

- **Issues**: [GitHub Issues](../../issues)
- **Discussions**: [GitHub Discussions](../../discussions)

---

<div align="center">

**⭐ If you find NukeIT useful, please consider giving it a star! ⭐**

Made with ❤️ for the Windows community

</div>
