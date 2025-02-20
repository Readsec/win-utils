# Function to display the banner
function Show-Banner {
    Clear-Host
    Write-Host @"

__________                               .__        
\______   \_______   ____  ________  _  _|__| ____  
 |     ___/\_  __ \_/ __ \/ ____/\ \/ \/ /  |/    \ 
 |    |     |  | \/\  ___< <_|  | \     /|  |   |  \
 |____|     |__|    \___  >__   |  \/\_/ |__|___|  /
                        \/   |__|                \/ 

"@ -ForegroundColor Cyan
	
	Write-Host "                    A Windows Internal VA Prerequisite Checker`n" -ForegroundColor Green
    Write-Host "                    || Developed by Akshay aka Readsec ||`n" -ForegroundColor Green
}

# Function to check if the current user has administrative privileges
function Test-Admin {
    $currentUser = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    return $currentUser.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

# Function to check if WMI is enabled
function Test-WMI {
    try {
        $wmiService = Get-Service -Name Winmgmt -ErrorAction Stop
        return $wmiService.Status -eq 'Running'
    } catch {
        return $false
    }
}

# Function to check if ports 139 and 445 are open
function Test-Ports {
    $port139 = Test-NetConnection -ComputerName localhost -Port 139 -ErrorAction SilentlyContinue
    $port445 = Test-NetConnection -ComputerName localhost -Port 445 -ErrorAction SilentlyContinue
    return ($port139.TcpTestSucceeded -and $port445.TcpTestSucceeded)
}

# Function to check if File & Print Sharing is enabled
function Test-FilePrintSharing {
    try {
        $sharing = Get-SmbServerConfiguration -ErrorAction Stop
        return ($sharing.EnableFileSharing -eq $true -and $sharing.EnablePrintSharing -eq $true)
    } catch {
        return $false
    }
}

# Function to check if Remote Registry Service is enabled
function Test-RemoteRegistry {
    try {
        $remoteRegistry = Get-Service -Name RemoteRegistry -ErrorAction Stop
        return $remoteRegistry.Status -eq 'Running'
    } catch {
        return $false
    }
}

# Function to check if default admin shares are enabled
function Test-AdminShares {
    try {
        $adminShares = Get-SmbShare | Where-Object { $_.Name -eq 'ADMIN$' -or $_.Name -eq 'IPC$' }
        return ($adminShares.Count -eq 2)
    } catch {
        return $false
    }
}

# Function to check if LocalAccountTokenFilterPolicy is set to 1
function Test-LocalAccountTokenFilterPolicy {
    $keyPath = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System'
    $keyName = 'LocalAccountTokenFilterPolicy'
    try {
        $keyValue = (Get-ItemProperty -Path $keyPath -Name $keyName -ErrorAction Stop).$keyName
        return ($keyValue -eq 1)
    } catch {
        return $false
    }
}

# Function to set LocalAccountTokenFilterPolicy to 1
function Set-LocalAccountTokenFilterPolicy {
    $keyPath = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System'
    $keyName = 'LocalAccountTokenFilterPolicy'
    try {
        if (-not (Test-Path $keyPath)) {
            New-Item -Path $keyPath -Force | Out-Null
        }
        Set-ItemProperty -Path $keyPath -Name $keyName -Value 1 -Type DWord -ErrorAction Stop
        Write-Host "Successfully set LocalAccountTokenFilterPolicy to 1." -ForegroundColor Green
    } catch {
        Write-Host "Failed to set LocalAccountTokenFilterPolicy to 1." -ForegroundColor Red
    }
}

# Main script execution
Show-Banner

Write-Host "WARNING: Please run this tool with Administrator privileges to ensure complete results." -ForegroundColor Yellow
Write-Host "WARNING: Symantec Antivirus or other protection systems may interfere with this tool." -ForegroundColor Yellow
Write-Host "WARNING: Symantec Antivirus has to be uninstalled or required Nessus files have to be whitelisted." -ForegroundColor Yellow
Write-Host "WARNING:  If any active protection are running please whitelist or disable it until the activity is completed." -ForegroundColor Yellow

if (-not (Test-Admin)) {
    Write-Host "This script must be run with administrative privileges. Please run as an administrator." -ForegroundColor Red
    exit
}

Write-Host "Starting system configuration checks..." -ForegroundColor Yellow

# Initialize a flag to track overall success
$allChecksPassed = $true

# Check WMI
if (-not (Test-WMI)) {
    Write-Host "WMI is not enabled. Enabling WMI..." -ForegroundColor Yellow
    try {
        Start-Service -Name Winmgmt -ErrorAction Stop
        Write-Host "WMI service started successfully." -ForegroundColor Green
    } catch {
        Write-Host "Failed to start WMI service." -ForegroundColor Red
        $allChecksPassed = $false
    }
} else {
    Write-Host "WMI is already enabled." -ForegroundColor Green
}

# Check Ports
if (-not (Test-Ports)) {
    Write-Host "Ports 139 and 445 are not open. Please ensure these ports are open on the target system." -ForegroundColor Red
    $allChecksPassed = $false
} else {
    Write-Host "Ports 139 and 445 are open." -ForegroundColor Green
}

# Check File & Print Sharing
if (-not (Test-FilePrintSharing)) {
    Write-Host "File & Print Sharing is not enabled. Enabling File & Print Sharing..." -ForegroundColor Yellow
    try {
        Set-SmbServerConfiguration -EnableFileSharing $true -EnablePrintSharing $true -Force -ErrorAction Stop
        Write-Host "File & Print Sharing enabled successfully." -ForegroundColor Green
    } catch {
        Write-Host "Failed to enable File & Print Sharing." -ForegroundColor Red
        $allChecksPassed = $false
    }
} else {
    Write-Host "File & Print Sharing is already enabled." -ForegroundColor Green
}

# Check Remote Registry Service
if (-not (Test-RemoteRegistry)) {
    Write-Host "Remote Registry Service is not enabled. Enabling Remote Registry Service..." -ForegroundColor Yellow
    try {
        Set-Service -Name RemoteRegistry -StartupType Automatic -ErrorAction Stop
        Start-Service -Name RemoteRegistry -ErrorAction Stop
        Write-Host "Remote Registry Service enabled successfully." -ForegroundColor Green
    } catch {
        Write-Host "Failed to enable Remote Registry Service." -ForegroundColor Red
        $allChecksPassed = $false
    }
} else {
    Write-Host "Remote Registry Service is already enabled." -ForegroundColor Green
}

# Check Default Admin Shares
if (-not (Test-AdminShares)) {
    Write-Host "Default admin shares are not enabled. Enabling default admin shares..." -ForegroundColor Yellow
    try {
        # Ensure ADMIN$ share exists
        if (-not (Get-SmbShare -Name 'ADMIN$' -ErrorAction SilentlyContinue)) {
            New-SmbShare -Name 'ADMIN$' -Path 'C:\Windows' -FullAccess 'Administrators' -ErrorAction Stop
        }
        # Ensure IPC$ share exists
        if (-not (Get-SmbShare -Name 'IPC$' -ErrorAction SilentlyContinue)) {
            New-SmbShare -Name 'IPC$' -Path 'C:\Windows' -FullAccess 'Administrators' -ErrorAction Stop
        }
        Write-Host "Default admin shares enabled successfully." -ForegroundColor Green
    } catch {
        Write-Host "Failed to enable default admin shares." -ForegroundColor Red
        $allChecksPassed = $false
    }
} else {
    Write-Host "Default admin shares are already enabled." -ForegroundColor Green
}

# Check LocalAccountTokenFilterPolicy
if (-not (Test-LocalAccountTokenFilterPolicy)) {
    Write-Host "LocalAccountTokenFilterPolicy is not set to 1. Setting it to 1..." -ForegroundColor Yellow
    Set-LocalAccountTokenFilterPolicy
    if (-not (Test-LocalAccountTokenFilterPolicy)) {
        Write-Host "Failed to set LocalAccountTokenFilterPolicy to 1." -ForegroundColor Red
        $allChecksPassed = $false
    } else {
        Write-Host "LocalAccountTokenFilterPolicy is now set to 1." -ForegroundColor Green
    }
} else {
    Write-Host "LocalAccountTokenFilterPolicy is already set to 1." -ForegroundColor Green
}

# Final output based on all checks
if ($allChecksPassed) {
    Write-Host "All prerequisites have been validated and configured correctly." -ForegroundColor Green
} else {
    Write-Host "Some prerequisites failed to validate or configure. Please review the errors above." -ForegroundColor Red
}

# Prompt user for next steps
Write-Host "Script execution completed. Press 'Q' to quit or 'R' to rerun the script." -ForegroundColor Cyan
$userInput = Read-Host "Enter your choice (Q/R)"

while ($userInput -notin @('Q', 'q', 'R', 'r')) {
    Write-Host "Invalid input. Please enter 'Q' to quit or 'R' to rerun the script." -ForegroundColor Red
    $userInput = Read-Host "Enter your choice (Q/R)"
}

if ($userInput -in @('Q', 'q')) {
    Write-Host "Exiting the script. Goodbye!" -ForegroundColor Yellow
    exit
} elseif ($userInput -in @('R', 'r')) {
    Write-Host "Rerunning the script..." -ForegroundColor Yellow
    . $MyInvocation.MyCommand.Path
}