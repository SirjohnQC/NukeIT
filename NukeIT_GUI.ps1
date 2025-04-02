Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force
Add-Type -AssemblyName "System.Windows.Forms"
Add-Type -TypeDefinition @"
    using System;
    using System.Runtime.InteropServices;
    public class Window {
        [DllImport("user32.dll")]
        public static extern int GetForegroundWindow();
    }
"@

# Define the correct file path to store the blocked apps
$blockedAppsFile = "$env:USERPROFILE\blocked_exes.txt"

# Create the Form
$form = New-Object System.Windows.Forms.Form
$form.Text = "NukeIT Exe Blocker"
$form.Size = New-Object System.Drawing.Size(400, 300)

# Create Folder Path Label
$label = New-Object System.Windows.Forms.Label
$label.Text = "Select a Folder to Block .exe Files:"
$label.Location = New-Object System.Drawing.Point(10, 20)
$form.Controls.Add($label)

# Create Folder Path TextBox
$textBox = New-Object System.Windows.Forms.TextBox
$textBox.Location = New-Object System.Drawing.Point(10, 50)
$textBox.Size = New-Object System.Drawing.Size(280, 20)
$form.Controls.Add($textBox)

# Create Browse Button
$browseButton = New-Object System.Windows.Forms.Button
$browseButton.Text = "Browse..."
$browseButton.Location = New-Object System.Drawing.Point(300, 50)
$browseButton.Add_Click({
    $folderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog
    if ($folderBrowser.ShowDialog() -eq "OK") {
        $textBox.Text = $folderBrowser.SelectedPath
    }
})
$form.Controls.Add($browseButton)

# Create NukeIT Button
$nukeButton = New-Object System.Windows.Forms.Button
$nukeButton.Text = "NukeIT"
$nukeButton.Location = New-Object System.Drawing.Point(10, 100)
$nukeButton.Size = New-Object System.Drawing.Size(120, 30)
$nukeButton.Add_Click({
    $folderPath = $textBox.Text
    if (Test-Path $folderPath) {
        # Get all .exe files in the folder and its subfolders
        $exeFiles = Get-ChildItem -Path $folderPath -Recurse -Filter "*.exe"
        $totalFiles = $exeFiles.Count
        $newlyBlockedCount = 0
        $alreadyBlockedCount = 0
        
        # Ensure the blocked_exes.txt file exists
        if (-not (Test-Path $blockedAppsFile)) {
            New-Item -Path $blockedAppsFile -ItemType File -Force | Out-Null
        }
        
        # Get existing blocked apps if the file exists and has content
        $existingBlocked = @()
        if ((Test-Path $blockedAppsFile) -and (Get-Item $blockedAppsFile).Length -gt 0) {
            $existingBlocked = Get-Content -Path $blockedAppsFile
        }
        
        foreach ($exe in $exeFiles) {
            $exePath = $exe.FullName
            $outboundRuleName = "Block $($exe.Name) from Internet (Outbound)"
            $inboundRuleName = "Block $($exe.Name) from Internet (Inbound)"
            
            # Check if rules already exist
            $outboundRuleExists = Get-NetFirewallRule -DisplayName $outboundRuleName -ErrorAction SilentlyContinue
            $inboundRuleExists = Get-NetFirewallRule -DisplayName $inboundRuleName -ErrorAction SilentlyContinue
            
            if ($outboundRuleExists -and $inboundRuleExists) {
                $alreadyBlockedCount++
                
                # Make sure it's in our tracking file
                if ($existingBlocked -notcontains $exePath) {
                    Add-Content -Path $blockedAppsFile -Value $exePath
                }
                continue
            }
            
            # Create a new outbound rule if it doesn't exist
            if (-not $outboundRuleExists) {
                New-NetFirewallRule -DisplayName $outboundRuleName `
                                    -Direction Outbound `
                                    -Program $exePath `
                                    -Action Block `
                                    -Profile Any `
                                    -Enabled True
            }
            
            # Create a new inbound rule if it doesn't exist
            if (-not $inboundRuleExists) {
                New-NetFirewallRule -DisplayName $inboundRuleName `
                                    -Direction Inbound `
                                    -Program $exePath `
                                    -Action Block `
                                    -Profile Any `
                                    -Enabled True
            }
            
            # Save the blocked .exe path to the file if not already there
            if ($existingBlocked -notcontains $exePath) {
                Add-Content -Path $blockedAppsFile -Value $exePath
            }
            
            $newlyBlockedCount++
        }
        
        if ($alreadyBlockedCount -gt 0 -and $newlyBlockedCount -gt 0) {
            [System.Windows.Forms.MessageBox]::Show("$newlyBlockedCount new .exe files have been blocked.`n$alreadyBlockedCount files were already blocked.", "NukeIT Partial Success")
        } elseif ($alreadyBlockedCount -gt 0 -and $newlyBlockedCount -eq 0) {
            [System.Windows.Forms.MessageBox]::Show("All $alreadyBlockedCount .exe files in this folder are already blocked in the firewall.", "NukeIT Info")
        } else {
            [System.Windows.Forms.MessageBox]::Show("All $newlyBlockedCount .exe files in this folder have been blocked from accessing the internet.", "NukeIT Success")
        }
    } else {
        [System.Windows.Forms.MessageBox]::Show("Invalid folder path!", "Error")
    }
})

$form.Controls.Add($nukeButton)

# Create Un-NukeIT Button
$unNukeButton = New-Object System.Windows.Forms.Button
$unNukeButton.Text = "Un-NukeIT"
$unNukeButton.Location = New-Object System.Drawing.Point(150, 100)
$unNukeButton.Size = New-Object System.Drawing.Size(120, 30)
$unNukeButton.Add_Click({
    $folderPath = $textBox.Text
    if (Test-Path $folderPath) {
        # Read the blocked apps list from the text file
        if (Test-Path $blockedAppsFile) {
            $blockedApps = Get-Content -Path $blockedAppsFile
            $removedCount = 0
            
            foreach ($app in $blockedApps) {
                $appName = Split-Path $app -Leaf
                $outboundRuleName = "Block $appName from Internet (Outbound)"
                $inboundRuleName = "Block $appName from Internet (Inbound)"
                
                # Remove the firewall rules for each blocked app (both inbound and outbound)
                $outboundRemoved = Remove-NetFirewallRule -DisplayName $outboundRuleName -ErrorAction SilentlyContinue
                $inboundRemoved = Remove-NetFirewallRule -DisplayName $inboundRuleName -ErrorAction SilentlyContinue
                
                if ($outboundRemoved -or $inboundRemoved) {
                    $removedCount++
                }
            }
            
            # Clear the blocked apps list after unblocking
            Clear-Content -Path $blockedAppsFile
            
            if ($removedCount -gt 0) {
                [System.Windows.Forms.MessageBox]::Show("$removedCount .exe files have been unblocked.", "Un-NukeIT Success")
            } else {
                [System.Windows.Forms.MessageBox]::Show("No active firewall rules were found for these applications.", "Un-NukeIT Info")
            }
        } else {
            [System.Windows.Forms.MessageBox]::Show("No blocked apps found! The file blocked_exes.txt does not exist.", "Error")
        }
    } else {
        [System.Windows.Forms.MessageBox]::Show("Invalid folder path!", "Error")
    }
})

$form.Controls.Add($unNukeButton)

# Run the form
[void]$form.ShowDialog()