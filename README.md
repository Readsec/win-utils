**PreqWin - Windows Prerequisite Configuration checks Tool**

## Overview

PreqWin is a PowerShell-based tool designed to automate the configuration of essential prerequisites on Windows systems. It ensures that critical services, settings, and configurations are properly enabled or configured before performing advanced tasks such as vulnerability scanning, system auditing, or network diagnostics. The tool simplifies the process of preparing a Windows environment by performing checks and applying necessary changes automatically.

## Key Features

- **Automated Checks**: Verifies the status of critical services like WMI, File & Print Sharing, Remote Registry, and default admin shares.
- **Port Validation**: Ensures that required ports (139 and 445) are open for communication.
- **Registry Modifications**: Configures the LocalAccountTokenFilterPolicy registry key to allow remote access for local accounts.
- **Error Handling**: Provides clear feedback for each step, indicating success or failure.
- **Interactive Execution**: Allows users to rerun the script or exit after completion.
- **Admin Privileges Enforcement**: Ensures the script runs with administrative privileges to avoid permission issues.

## How It Works

The tool performs the following steps:

1. **Administrative Privileges Check**: Ensures the script is executed with administrator rights.
2. **System Configuration Checks**:
   - Verifies if the WMI service is running.
   - Checks if ports 139 and 445 are open.
   - Validates that File & Print Sharing is enabled.
   - Ensures the Remote Registry service is active.
   - Confirms the existence of default admin shares (ADMIN\$ and IPC\$).
   - Checks if the LocalAccountTokenFilterPolicy registry key is set to 1.
3. **Automatic Fixes**: If any prerequisite is not met, the tool attempts to configure it automatically.
4. **Detailed Feedback**: Displays success or failure messages for each step, along with actionable recommendations for unresolved issues.

## Use Cases

PreqWin is particularly useful in scenarios where:

- Preparing a Windows machine for vulnerability scanning tools like Nessus.
- Configuring a system for remote administration or diagnostics.
- Ensuring compliance with specific security or operational requirements.
- Automating repetitive tasks during system audits or penetration testing.

## Prerequisites

Before running the tool, ensure the following:

- **PowerShell**: The script requires PowerShell.
- **Administrative Privileges**: The script must be executed with administrator rights.
- **Execution Policy**: Adjust the PowerShell execution policy to allow script execution:
  
  Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
  Set-ExecutionPolicy RemoteSigned -Scope LocalMachine -Force
  Set-ExecutionPolicy RemoteSigned -Scope Process -Force
  Unblock-File -Path "PATH"

## How to Use the Tool

### Step 1: Download the Script

Clone the repository or download the preqwin.psl script from GitHub:

git clone https://github.com/Readsec/win-utils.git

Navigate to the directory containing the script:

Open powershell
cd path\to\Preqwin


### Step 2: Run the Script

Open PowerShell as an administrator:

- Press **Win + S**, type **PowerShell**, right-click, and select **Run as Administrator**.

Execute the script:

Open powershell with Admin privillages
.\preqwin.ps1

### Step 3: Follow On-Screen Instructions

- The script will perform a series of checks.
- For each check, it will indicate whether the prerequisite is already configured or needs to be fixed.
- If any issue arises, follow the on-screen recommendations to resolve it manually or rerun the script.

### Step 4: Review Results

Upon completion, the script will summarize the results:

- **Success**: All prerequisites have been validated and configured correctly.
- **Failure**: Some prerequisites failed to validate or configure. Review the errors and take corrective actions.

### Step 5: Rerun or Exit

After execution, you can choose to:

- Press **Q** to quit.
- Press **R** to rerun the script.

## Troubleshooting

### Execution Policy Errors

If you encounter an error about the script being blocked, adjust the execution policy:

Tyoe the following command in PowerShell:
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
Set-ExecutionPolicy RemoteSigned -Scope LocalMachine -Force
Set-ExecutionPolicy RemoteSigned -Scope Process -Force
Unblock-File -Path "PATH"

### Insufficient Permissions

Ensure the script is run as an administrator. Without admin rights, certain configurations cannot be applied.

### Antivirus Interference

If antivirus software blocks the script, temporarily disable it or whitelist the script file.

## Contributing

Contributions to PreqWin are welcome! If you find a bug or want to add new features, feel free to:

1. Fork the repository.
2. Create a new branch for your changes.
3. Submit a pull request with a detailed description of your changes.

## Acknowledgments

**Developed by Akshay**
