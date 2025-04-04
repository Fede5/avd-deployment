# AVD Deployment Automation with Bicep

This project demonstrates the deployment of an Azure Virtual Desktop (AVD) environment using Bicep templates and PowerShell scripting. It includes:

- Creation of a Host Pool
- Setup of a Desktop Application Group
- Configuration of a Workspace
- Script to register the Application Group into the Workspace

## 📁 Files

- `main.bicep`: Infrastructure-as-code for the AVD environment.
- `publish-appgroup.ps1`: PowerShell script to register the application group into the workspace.

## 🔧 Requirements

- Azure CLI / PowerShell with Az module
- Bicep CLI
- Azure subscription with required permissions

## 🚀 Deployment

1. Deploy the Bicep file:

```bash
az deployment group create --resource-group rg-avd --template-file main.bicep --parameters hostPoolName="avd-hostpool" workspaceName="avd-workspace" adminUsername="adminuser"
```

2. Run the PowerShell script to publish the App Group:

```powershell
./publish-appgroup.ps1
```

## ✅ Notes

This deployment can be extended with session host creation, FSLogix profile configuration, and diagnostics settings.