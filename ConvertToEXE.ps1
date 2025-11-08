# PowerShell to EXE Converter using PS2EXE
# This script will download PS2EXE and convert your .ps1 file to .exe

param(
    [string]$InputScript = "",
    [string]$OutputExe = "",
    [switch]$RequireAdmin = $true,
    [switch]$NoConsole = $true
)

# Function to install PS2EXE if not already installed
function Install-PS2EXE {
    Write-Host "Checking for PS2EXE module..." -ForegroundColor Cyan
    
    if (-not (Get-Module -ListAvailable -Name ps2exe)) {
        Write-Host "PS2EXE not found. Installing..." -ForegroundColor Yellow
        try {
            Install-Module -Name ps2exe -Scope CurrentUser -Force -AllowClobber
            Write-Host "PS2EXE installed successfully!" -ForegroundColor Green
        } catch {
            Write-Host "Error installing PS2EXE: $_" -ForegroundColor Red
            Write-Host ""
            Write-Host "Trying alternative installation method..." -ForegroundColor Yellow
            Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
            Install-Module -Name ps2exe -Scope CurrentUser -Force -AllowClobber
        }
    } else {
        Write-Host "PS2EXE is already installed!" -ForegroundColor Green
    }
    
    Import-Module ps2exe
}

# Function to convert PS1 to EXE
function Convert-PS1toEXE {
    param(
        [string]$InputFile,
        [string]$OutputFile,
        [bool]$Admin,
        [bool]$NoConsoleWindow
    )
    
    if (-not (Test-Path $InputFile)) {
        Write-Host "Error: Input file '$InputFile' not found!" -ForegroundColor Red
        return $false
    }
    
    Write-Host ""
    Write-Host "Converting '$InputFile' to EXE..." -ForegroundColor Cyan
    Write-Host "Output: $OutputFile" -ForegroundColor Cyan
    
    try {
        $params = @{
            InputFile = $InputFile
            OutputFile = $OutputFile
            NoConsole = $NoConsoleWindow
            RequireAdmin = $Admin
            NoError = $true
            NoOutput = $false
        }
        
        Invoke-PS2EXE @params
        
        if (Test-Path $OutputFile) {
            Write-Host ""
            Write-Host "SUCCESS! EXE created: $OutputFile" -ForegroundColor Green
            $fileSize = (Get-Item $OutputFile).Length / 1KB
            Write-Host ""
            Write-Host "File size: $fileSize KB" -ForegroundColor Cyan
            return $true
        } else {
            Write-Host ""
            Write-Host "FAILED! EXE was not created." -ForegroundColor Red
            return $false
        }
    } catch {
        Write-Host ""
        Write-Host "ERROR during conversion: $_" -ForegroundColor Red
        return $false
    }
}

# Main Script
Clear-Host
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  PowerShell to EXE Converter" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Install PS2EXE if needed
Install-PS2EXE

Write-Host ""

# If no parameters provided, ask for input
if ([string]::IsNullOrWhiteSpace($InputScript)) {
    $InputScript = Read-Host "Enter the path to your .ps1 file"
}

# Generate output filename if not provided
if ([string]::IsNullOrWhiteSpace($OutputExe)) {
    $OutputExe = [System.IO.Path]::ChangeExtension($InputScript, ".exe")
}

# Display conversion settings
Write-Host ""
Write-Host "Conversion Settings:" -ForegroundColor Yellow
Write-Host "  Input File:      $InputScript"
Write-Host "  Output File:     $OutputExe"
Write-Host "  Require Admin:   $RequireAdmin"
Write-Host "  No Console:      $NoConsole"
Write-Host ""

$confirm = Read-Host "Proceed with conversion? (Y/N)"

if ($confirm -eq "Y" -or $confirm -eq "y") {
    $success = Convert-PS1toEXE -InputFile $InputScript -OutputFile $OutputExe -Admin $RequireAdmin -NoConsoleWindow $NoConsole
    
    if ($success) {
        Write-Host ""
        Write-Host "Your executable is ready to use!" -ForegroundColor Green
        Write-Host ""
        $open = Read-Host "Open folder containing the EXE? (Y/N)"
        if ($open -eq "Y" -or $open -eq "y") {
            explorer.exe /select,"$OutputExe"
        }
    }
} else {
    Write-Host "Conversion cancelled." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Press any key to exit..."
$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')