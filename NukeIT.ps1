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

# Define file paths
$blockedAppsFile = "$env:USERPROFILE\blocked_exes.txt"
$blockedWebsitesFile = "$env:USERPROFILE\blocked_websites.txt"
$hostsFile = "$env:SystemRoot\System32\drivers\etc\hosts"

# Create the Form
$form = New-Object System.Windows.Forms.Form
$form.Text = "NukeIT Enhanced - Exe & Website Blocker"
$form.Size = New-Object System.Drawing.Size(500, 580)

# ===== EXE BLOCKING SECTION =====
$exeLabel = New-Object System.Windows.Forms.Label
$exeLabel.Text = "===== BLOCK .EXE FILES ====="
$exeLabel.Location = New-Object System.Drawing.Point(10, 10)
$exeLabel.Font = New-Object System.Drawing.Font("Arial", 10, [System.Drawing.FontStyle]::Bold)
$exeLabel.AutoSize = $true
$form.Controls.Add($exeLabel)

# Create Folder Path Label
$label = New-Object System.Windows.Forms.Label
$label.Text = "Select a Folder to Block .exe Files:"
$label.Location = New-Object System.Drawing.Point(10, 40)
$label.AutoSize = $true
$form.Controls.Add($label)

# Create Folder Path TextBox
$textBox = New-Object System.Windows.Forms.TextBox
$textBox.Location = New-Object System.Drawing.Point(10, 65)
$textBox.Size = New-Object System.Drawing.Size(370, 20)
$form.Controls.Add($textBox)

# Create Browse Button
$browseButton = New-Object System.Windows.Forms.Button
$browseButton.Text = "Browse..."
$browseButton.Location = New-Object System.Drawing.Point(390, 63)
$browseButton.Size = New-Object System.Drawing.Size(80, 25)
$browseButton.Add_Click({
    $folderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog
    if ($folderBrowser.ShowDialog() -eq "OK") {
        $textBox.Text = $folderBrowser.SelectedPath
    }
})
$form.Controls.Add($browseButton)

# Create NukeIT Button
$nukeButton = New-Object System.Windows.Forms.Button
$nukeButton.Text = "NukeIT (Block)"
$nukeButton.Location = New-Object System.Drawing.Point(10, 100)
$nukeButton.Size = New-Object System.Drawing.Size(110, 30)
$nukeButton.Add_Click({
    $folderPath = $textBox.Text
    if (Test-Path $folderPath) {
        $exeFiles = Get-ChildItem -Path $folderPath -Recurse -Filter "*.exe"
        $totalFiles = $exeFiles.Count
        $newlyBlockedCount = 0
        $alreadyBlockedCount = 0
        
        if (-not (Test-Path $blockedAppsFile)) {
            New-Item -Path $blockedAppsFile -ItemType File -Force | Out-Null
        }
        
        $existingBlocked = @()
        if ((Test-Path $blockedAppsFile) -and (Get-Item $blockedAppsFile).Length -gt 0) {
            $existingBlocked = Get-Content -Path $blockedAppsFile
        }
        
        foreach ($exe in $exeFiles) {
            $exePath = $exe.FullName
            $outboundRuleName = "Block $($exe.Name) from Internet (Outbound)"
            $inboundRuleName = "Block $($exe.Name) from Internet (Inbound)"
            
            $outboundRuleExists = Get-NetFirewallRule -DisplayName $outboundRuleName -ErrorAction SilentlyContinue
            $inboundRuleExists = Get-NetFirewallRule -DisplayName $inboundRuleName -ErrorAction SilentlyContinue
            
            if ($outboundRuleExists -and $inboundRuleExists) {
                $alreadyBlockedCount++
                if ($existingBlocked -notcontains $exePath) {
                    Add-Content -Path $blockedAppsFile -Value $exePath
                }
                continue
            }
            
            if (-not $outboundRuleExists) {
                New-NetFirewallRule -DisplayName $outboundRuleName `
                                    -Direction Outbound `
                                    -Program $exePath `
                                    -Action Block `
                                    -Profile Any `
                                    -Enabled True
            }
            
            if (-not $inboundRuleExists) {
                New-NetFirewallRule -DisplayName $inboundRuleName `
                                    -Direction Inbound `
                                    -Program $exePath `
                                    -Action Block `
                                    -Profile Any `
                                    -Enabled True
            }
            
            if ($existingBlocked -notcontains $exePath) {
                Add-Content -Path $blockedAppsFile -Value $exePath
            }
            
            $newlyBlockedCount++
        }
        
        if ($alreadyBlockedCount -gt 0 -and $newlyBlockedCount -gt 0) {
            [System.Windows.Forms.MessageBox]::Show("$newlyBlockedCount new .exe files blocked.`n$alreadyBlockedCount were already blocked.", "NukeIT Partial Success")
        } elseif ($alreadyBlockedCount -gt 0 -and $newlyBlockedCount -eq 0) {
            [System.Windows.Forms.MessageBox]::Show("All $alreadyBlockedCount .exe files are already blocked.", "NukeIT Info")
        } else {
            [System.Windows.Forms.MessageBox]::Show("$newlyBlockedCount .exe files blocked from internet.", "NukeIT Success")
        }
    } else {
        [System.Windows.Forms.MessageBox]::Show("Invalid folder path!", "Error")
    }
})
$form.Controls.Add($nukeButton)

# Create Un-NukeIT Button
$unNukeButton = New-Object System.Windows.Forms.Button
$unNukeButton.Text = "Un-NukeIT"
$unNukeButton.Location = New-Object System.Drawing.Point(130, 100)
$unNukeButton.Size = New-Object System.Drawing.Size(110, 30)
$unNukeButton.Add_Click({
    if (Test-Path $blockedAppsFile) {
        $blockedApps = Get-Content -Path $blockedAppsFile
        $removedCount = 0
        
        foreach ($app in $blockedApps) {
            $appName = Split-Path $app -Leaf
            $outboundRuleName = "Block $appName from Internet (Outbound)"
            $inboundRuleName = "Block $appName from Internet (Inbound)"
            
            $outboundRemoved = Remove-NetFirewallRule -DisplayName $outboundRuleName -ErrorAction SilentlyContinue
            $inboundRemoved = Remove-NetFirewallRule -DisplayName $inboundRuleName -ErrorAction SilentlyContinue
            
            if ($outboundRemoved -or $inboundRemoved) {
                $removedCount++
            }
        }
        
        Clear-Content -Path $blockedAppsFile
        
        if ($removedCount -gt 0) {
            [System.Windows.Forms.MessageBox]::Show("$removedCount .exe files unblocked.", "Un-NukeIT Success")
        } else {
            [System.Windows.Forms.MessageBox]::Show("No active firewall rules found.", "Un-NukeIT Info")
        }
    } else {
        [System.Windows.Forms.MessageBox]::Show("No blocked apps found!", "Error")
    }
})
$form.Controls.Add($unNukeButton)

# View Blocked EXEs Button
$viewExeButton = New-Object System.Windows.Forms.Button
$viewExeButton.Text = "View Blocked"
$viewExeButton.Location = New-Object System.Drawing.Point(250, 100)
$viewExeButton.Size = New-Object System.Drawing.Size(110, 30)
$viewExeButton.Add_Click({
    if (Test-Path $blockedAppsFile) {
        $blockedApps = Get-Content -Path $blockedAppsFile
        if ($blockedApps.Count -gt 0) {
            $message = "Blocked EXE Files ($($blockedApps.Count) total):`n`n"
            foreach ($app in $blockedApps) {
                $appName = Split-Path $app -Leaf
                $message += "• $appName`n"
            }
            [System.Windows.Forms.MessageBox]::Show($message, "Blocked EXEs", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
        } else {
            [System.Windows.Forms.MessageBox]::Show("No blocked EXE files found.", "Info")
        }
    } else {
        [System.Windows.Forms.MessageBox]::Show("No blocked EXE files found.", "Info")
    }
})
$form.Controls.Add($viewExeButton)

# ===== WEBSITE/IP BLOCKING SECTION =====
$webLabel = New-Object System.Windows.Forms.Label
$webLabel.Text = "===== BLOCK WEBSITES/IPs ====="
$webLabel.Location = New-Object System.Drawing.Point(10, 150)
$webLabel.Font = New-Object System.Drawing.Font("Arial", 10, [System.Drawing.FontStyle]::Bold)
$webLabel.AutoSize = $true
$form.Controls.Add($webLabel)

$webInputLabel = New-Object System.Windows.Forms.Label
$webInputLabel.Text = "Enter Website or IP (e.g., facebook.com or 192.168.1.1):"
$webInputLabel.Location = New-Object System.Drawing.Point(10, 180)
$webInputLabel.AutoSize = $true
$form.Controls.Add($webInputLabel)

# Website/IP TextBox
$webTextBox = New-Object System.Windows.Forms.TextBox
$webTextBox.Location = New-Object System.Drawing.Point(10, 205)
$webTextBox.Size = New-Object System.Drawing.Size(460, 20)
$form.Controls.Add($webTextBox)

# Block Website Button
$blockWebButton = New-Object System.Windows.Forms.Button
$blockWebButton.Text = "Block Website/IP"
$blockWebButton.Location = New-Object System.Drawing.Point(10, 240)
$blockWebButton.Size = New-Object System.Drawing.Size(110, 30)
$blockWebButton.Add_Click({
    $website = $webTextBox.Text.Trim()
    
    if ([string]::IsNullOrWhiteSpace($website)) {
        [System.Windows.Forms.MessageBox]::Show("Please enter a website or IP address!", "Error")
        return
    }
    
    # Remove protocol if present
    $website = $website -replace '^https?://', ''
    $website = $website -replace '^www\.', ''
    $website = $website.Split('/')[0]
    
    try {
        if (-not (Test-Path $blockedWebsitesFile)) {
            New-Item -Path $blockedWebsitesFile -ItemType File -Force | Out-Null
        }
        
        $existingBlocked = @()
        if ((Test-Path $blockedWebsitesFile) -and (Get-Item $blockedWebsitesFile).Length -gt 0) {
            $existingBlocked = Get-Content -Path $blockedWebsitesFile
        }
        
        if ($existingBlocked -contains $website) {
            [System.Windows.Forms.MessageBox]::Show("$website is already blocked!", "Info")
            return
        }
        
        $hostsEntry = "127.0.0.1 $website"
        $hostsEntryWWW = "127.0.0.1 www.$website"
        
        $hostsContent = Get-Content -Path $hostsFile -ErrorAction Stop
        
        $alreadyInHosts = $false
        foreach ($line in $hostsContent) {
            if ($line -match "127\.0\.0\.1\s+$website") {
                $alreadyInHosts = $true
                break
            }
        }
        
        if (-not $alreadyInHosts) {
            Add-Content -Path $hostsFile -Value "`n# Blocked by NukeIT"
            Add-Content -Path $hostsFile -Value $hostsEntry
            Add-Content -Path $hostsFile -Value $hostsEntryWWW
        }
        
        Add-Content -Path $blockedWebsitesFile -Value $website
        
        ipconfig /flushdns | Out-Null
        
        [System.Windows.Forms.MessageBox]::Show("$website has been blocked!", "Success")
        $webTextBox.Clear()
        
    } catch {
        [System.Windows.Forms.MessageBox]::Show("Error: $_`n`nMake sure you're running as Administrator!", "Error")
    }
})
$form.Controls.Add($blockWebButton)

# Unblock Website Button
$unblockWebButton = New-Object System.Windows.Forms.Button
$unblockWebButton.Text = "Unblock Website"
$unblockWebButton.Location = New-Object System.Drawing.Point(130, 240)
$unblockWebButton.Size = New-Object System.Drawing.Size(110, 30)
$unblockWebButton.Add_Click({
    $website = $webTextBox.Text.Trim()
    
    if ([string]::IsNullOrWhiteSpace($website)) {
        [System.Windows.Forms.MessageBox]::Show("Please enter a website or IP address!", "Error")
        return
    }
    
    $website = $website -replace '^https?://', ''
    $website = $website -replace '^www\.', ''
    $website = $website.Split('/')[0]
    
    try {
        if (-not (Test-Path $blockedWebsitesFile)) {
            [System.Windows.Forms.MessageBox]::Show("No blocked websites found!", "Info")
            return
        }
        
        $blockedSites = Get-Content -Path $blockedWebsitesFile
        
        if ($blockedSites -notcontains $website) {
            [System.Windows.Forms.MessageBox]::Show("$website is not in the blocked list!", "Info")
            return
        }
        
        $hostsContent = Get-Content -Path $hostsFile
        $newHostsContent = @()
        
        foreach ($line in $hostsContent) {
            if ($line -match "# Blocked by NukeIT") {
                continue
            }
            if ($line -match "127\.0\.0\.1\s+(www\.)?$website") {
                continue
            }
            $newHostsContent += $line
        }
        
        Set-Content -Path $hostsFile -Value $newHostsContent
        
        $updatedBlocked = $blockedSites | Where-Object { $_ -ne $website }
        Set-Content -Path $blockedWebsitesFile -Value $updatedBlocked
        
        ipconfig /flushdns | Out-Null
        
        [System.Windows.Forms.MessageBox]::Show("$website has been unblocked!", "Success")
        $webTextBox.Clear()
        
    } catch {
        [System.Windows.Forms.MessageBox]::Show("Error: $_`n`nMake sure you're running as Administrator!", "Error")
    }
})
$form.Controls.Add($unblockWebButton)

# View Blocked Websites Button
$viewWebButton = New-Object System.Windows.Forms.Button
$viewWebButton.Text = "View Blocked"
$viewWebButton.Location = New-Object System.Drawing.Point(250, 240)
$viewWebButton.Size = New-Object System.Drawing.Size(110, 30)
$viewWebButton.Add_Click({
    if (Test-Path $blockedWebsitesFile) {
        $blockedSites = Get-Content -Path $blockedWebsitesFile
        if ($blockedSites.Count -gt 0) {
            $message = "Blocked Websites ($($blockedSites.Count) total):`n`n"
            foreach ($site in $blockedSites) {
                $message += "• $site`n"
            }
            [System.Windows.Forms.MessageBox]::Show($message, "Blocked Websites", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
        } else {
            [System.Windows.Forms.MessageBox]::Show("No blocked websites found.", "Info")
        }
    } else {
        [System.Windows.Forms.MessageBox]::Show("No blocked websites found.", "Info")
    }
})
$form.Controls.Add($viewWebButton)

# Unblock All Websites Button
$unblockAllWebButton = New-Object System.Windows.Forms.Button
$unblockAllWebButton.Text = "Unblock ALL Websites"
$unblockAllWebButton.Location = New-Object System.Drawing.Point(10, 280)
$unblockAllWebButton.Size = New-Object System.Drawing.Size(350, 30)
$unblockAllWebButton.Add_Click({
    if (-not (Test-Path $blockedWebsitesFile)) {
        [System.Windows.Forms.MessageBox]::Show("No blocked websites found!", "Info")
        return
    }
    
    $result = [System.Windows.Forms.MessageBox]::Show("Are you sure you want to unblock ALL websites?", "Confirm", [System.Windows.Forms.MessageBoxButtons]::YesNo)
    
    if ($result -eq "Yes") {
        try {
            $blockedSites = Get-Content -Path $blockedWebsitesFile
            
            $hostsContent = Get-Content -Path $hostsFile
            $newHostsContent = @()
            
            foreach ($line in $hostsContent) {
                $shouldSkip = $false
                if ($line -match "# Blocked by NukeIT") {
                    $shouldSkip = $true
                }
                foreach ($site in $blockedSites) {
                    if ($line -match "127\.0\.0\.1\s+(www\.)?$site") {
                        $shouldSkip = $true
                        break
                    }
                }
                if (-not $shouldSkip) {
                    $newHostsContent += $line
                }
            }
            
            Set-Content -Path $hostsFile -Value $newHostsContent
            Clear-Content -Path $blockedWebsitesFile
            
            ipconfig /flushdns | Out-Null
            
            [System.Windows.Forms.MessageBox]::Show("All websites have been unblocked!", "Success")
            
        } catch {
            [System.Windows.Forms.MessageBox]::Show("Error: $_`n`nMake sure you're running as Administrator!", "Error")
        }
    }
})
$form.Controls.Add($unblockAllWebButton)

# ===== TESTING SECTION =====
$testLabel = New-Object System.Windows.Forms.Label
$testLabel.Text = "===== TEST BLOCKING ====="
$testLabel.Location = New-Object System.Drawing.Point(10, 330)
$testLabel.Font = New-Object System.Drawing.Font("Arial", 10, [System.Drawing.FontStyle]::Bold)
$testLabel.AutoSize = $true
$form.Controls.Add($testLabel)

$testInputLabel = New-Object System.Windows.Forms.Label
$testInputLabel.Text = "Enter website to test (e.g., facebook.com):"
$testInputLabel.Location = New-Object System.Drawing.Point(10, 360)
$testInputLabel.AutoSize = $true
$form.Controls.Add($testInputLabel)

# Test TextBox
$testTextBox = New-Object System.Windows.Forms.TextBox
$testTextBox.Location = New-Object System.Drawing.Point(10, 385)
$testTextBox.Size = New-Object System.Drawing.Size(460, 20)
$form.Controls.Add($testTextBox)

# Test Button
$testButton = New-Object System.Windows.Forms.Button
$testButton.Text = "Test Website Block"
$testButton.Location = New-Object System.Drawing.Point(10, 420)
$testButton.Size = New-Object System.Drawing.Size(150, 30)
$testButton.Add_Click({
    $testSite = $testTextBox.Text.Trim()
    
    if ([string]::IsNullOrWhiteSpace($testSite)) {
        [System.Windows.Forms.MessageBox]::Show("Please enter a website to test!", "Error")
        return
    }
    
    $testSite = $testSite -replace '^https?://', ''
    $testSite = $testSite -replace '^www\.', ''
    $testSite = $testSite.Split('/')[0]
    
    try {
        # Check if in hosts file
        $hostsContent = Get-Content -Path $hostsFile
        $blockedInHosts = $false
        
        foreach ($line in $hostsContent) {
            if ($line -match "127\.0\.0\.1\s+(www\.)?$testSite") {
                $blockedInHosts = $true
                break
            }
        }
        
        # Check if in tracking file
        $inTrackingFile = $false
        if (Test-Path $blockedWebsitesFile) {
            $blockedSites = Get-Content -Path $blockedWebsitesFile
            if ($blockedSites -contains $testSite) {
                $inTrackingFile = $true
            }
        }
        
        # Try to resolve DNS
        $dnsResult = "Unknown"
        try {
            $resolved = [System.Net.Dns]::GetHostAddresses($testSite)
            if ($resolved[0].ToString() -eq "127.0.0.1") {
                $dnsResult = "Blocked (127.0.0.1)"
            } else {
                $dnsResult = "Not Blocked ($($resolved[0]))"
            }
        } catch {
            $dnsResult = "Cannot resolve"
        }
        
        $message = "Test Results for: $testSite`n`n"
        $message += "Hosts File Status: " + $(if ($blockedInHosts) { "BLOCKED ✓" } else { "Not blocked" }) + "`n"
        $message += "Tracking File: " + $(if ($inTrackingFile) { "Listed ✓" } else { "Not listed" }) + "`n"
        $message += "DNS Resolution: $dnsResult`n`n"
        
        if ($blockedInHosts -and $dnsResult -eq "Blocked (127.0.0.1)") {
            $message += "STATUS: Website is BLOCKED ✓"
            [System.Windows.Forms.MessageBox]::Show($message, "Test Result - BLOCKED", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
        } elseif ($blockedInHosts -and $dnsResult -ne "Blocked (127.0.0.1)") {
            $message += "STATUS: Hosts file has entry but DNS cache may need clearing.`nTry: ipconfig /flushdns"
            [System.Windows.Forms.MessageBox]::Show($message, "Test Result - PARTIAL", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning)
        } else {
            $message += "STATUS: Website is NOT BLOCKED"
            [System.Windows.Forms.MessageBox]::Show($message, "Test Result - NOT BLOCKED", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
        }
        
    } catch {
        [System.Windows.Forms.MessageBox]::Show("Error testing website: $_", "Error")
    }
})
$form.Controls.Add($testButton)

# Flush DNS Button
$flushDnsButton = New-Object System.Windows.Forms.Button
$flushDnsButton.Text = "Flush DNS Cache"
$flushDnsButton.Location = New-Object System.Drawing.Point(170, 420)
$flushDnsButton.Size = New-Object System.Drawing.Size(150, 30)
$flushDnsButton.Add_Click({
    try {
        ipconfig /flushdns | Out-Null
        [System.Windows.Forms.MessageBox]::Show("DNS cache has been flushed successfully!`n`nBlocked websites should now be unreachable.", "Success")
    } catch {
        [System.Windows.Forms.MessageBox]::Show("Error flushing DNS: $_", "Error")
    }
})
$form.Controls.Add($flushDnsButton)

# Info Label
$infoLabel = New-Object System.Windows.Forms.Label
$infoLabel.Text = "NOTE: You must run this script as Administrator to block websites!"
$infoLabel.Location = New-Object System.Drawing.Point(10, 500)
$infoLabel.Size = New-Object System.Drawing.Size(470, 40)
$infoLabel.ForeColor = [System.Drawing.Color]::Red
$form.Controls.Add($infoLabel)

# Run the form
[void]$form.ShowDialog()