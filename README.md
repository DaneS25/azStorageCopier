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
