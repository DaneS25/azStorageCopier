# Azure CLI and Az Module Setup

## Install Azure CLI

Run the following command to download and install Azure CLI on Windows:

```powershell
Invoke-WebRequest -Uri https://aka.ms/installazurecliwindows -OutFile .\AzureCLI.msi; Start-Process msiexec.exe -Wait -ArgumentList '/I AzureCLI.msi /quiet'; Remove-Item .\AzureCLI.msi
```

## Install Module Az

Install the ```Az``` module using the following command:

```powershell
Install-Module -Name Az -AllowClobber -Force -Scope CurrentUser
```

## Parameters:

- ```-Name Az```: Specifies the module to install.
- ```-AllowClobber: Allows```: overwriting existing commands.
- ```-Force```: Ensures the installation proceeds without prompts.
- ```-Scope CurrentUser```: Installs the module for the current user only.

## Import Az Module

After installation, import the ```Az``` module:

```powershell
Import-Module Az
```

## Verify Module Installation

To verify the installation, run:

```powershell
Get-Command -Module Az
```

## Check Azure CLI Version

Check the installed Azure CLI version:

```powershell
az --version
```

## Login to Azure CLI

Log in to Azure CLI to run scripts:

```powershell
az login
```

# Azure Storage Copy Script: User Instructions

This PowerShell script is designed to help you copy Azure Storage containers and their contents (blobs) from a **source storage account** to a **target storage account**. It uses Azure CLI and the ```Az``` module to authenticate, list resources, and perform the copy operation.

## Prerequisites

Before running the script, ensure the following:

1. **Azure CLI** is installed. (Refer to the Azure CLI installation instructions above.)
2. The **Az PowerShell module** is installed. (Refer to the Az module installation instructions above.)
3. You have **sufficient permissions** to access and manage the source and target storage accounts (Storage Blob Data Contributor)

## What the Script Does

1. **Authenticates** you to Azure using device code authentication.
   
3. **Lists all available subscriptions** and prompts you to select:
    - A **source subscription** (where the data is currently stored).
    - A **target subscription** (where the data will be copied to).
      
4. **Lists all resource groups** in the selected subscriptions and prompts you to select:
    - A **source resource group** (containing the source storage account).
    - A **target resource group** (containing the target storage account).
      
5. **Lists all storage accounts** in the selected resource groups and prompts you to select:
    - A **source storage account** (where the containers/blobs are located).
    - A **target storage account** (where the containers/blobs will be copied).
      
6. **Lists all containers** in the source storage account and prompts you to:
    - Select one or more containers to copy (or choose ```all``` to copy all containers).
      
7. **Copies the selected containers and their contents** to the target storage account:
    - If multiple containers are selected, they will be copied with the same names to the target.
    - If a target container does not exist, it will be created automatically.
      
8. Displays progress as each blob is copied and confirms when the operation is complete.

## How to Use the Script

1. Open **PowerShell** with administrative privileges.

2. Run the script.

3. Follow the on-screen prompts to:
    - Select the **source subscription**, **resource group**, and **storage account**.
    - Select the **containers** to copy.
    - Select the **target subscription**, **resource group**, and **storage account**.

4. Wait for the script to complete. It will display progress and confirm when the copy operation is finished.

## Notes

- **Device Code Authentication**: When you run the script, it will prompt you to authenticate using a device code. Follow the instructions in the terminal to complete the login process.
- **Multiple Containers**: If you select multiple containers or choose all, the script will skip the target container selection and use the same names as the source containers.
- **Blob Metadata**: The script does not copy blob metadata. Only the blob content is copied.

## Example Workflow

1. Run the script.
2. Authenticate to Azure when prompted.
3. Select the source subscription (e.g., ```Production```).
4. Select the source resource group (e.g., ```rg-production-storage```).
5. Select the source storage account (e.g., ```prodstorageaccount```).
6. Select the containers to copy (e.g., ```logs```, ```backups```, or ```all```).
7. Select the target subscription (e.g., ```Development```).
8. Select the target resource group (e.g., ```rg-development-storage```).
9. Select the target storage account (e.g., ```devstorageaccount```).
10. Wait for the script to complete. It will display progress and confirm when the copy is done.

## Troubleshooting

- **Invalid Input**: If you enter an invalid option, the script will prompt you to try again.
- **Missing Containers**: If a source container does not exist, the script will skip it and continue with the next container.
- **Permissions Issues**: Ensure you have the necessary permissions to access and manage both the source and target storage accounts.
