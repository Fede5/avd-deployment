# Azure Virtual Desktop Deployment Automation 🚀

![Azure](https://img.shields.io/badge/Azure-0078D4?logo=microsoftazure&logoColor=white)
![Bicep](https://img.shields.io/badge/Bicep-005BA1?logo=microsoft&logoColor=white)
![PowerShell](https://img.shields.io/badge/PowerShell-5391FE?logo=powershell&logoColor=white)
![Azure DevOps](https://img.shields.io/badge/Azure_DevOps-CB2C2F?logo=azuredevops&logoColor=white)
![CI/CD](https://img.shields.io/badge/CI/CD-Automated-green)

This project automates the deployment of a complete **Azure Virtual Desktop (AVD)** environment using **modular Bicep templates** and **Azure DevOps Pipelines**. It includes full automation of:

- 🧱 AVD infrastructure (Host pool, App Group, Workspace, Log Analytics)
- 💻 Session Hosts deployment with domain join and registration
- 🔐 Secure secrets handling via Azure Key Vault
- 📦 Parameterized and environment-based deployments

---

## 📁 Project Structure

```
📦 avd-deployment/
├── main.bicep               # Entry point for AVD core infrastructure
├── hostpool.bicep           # AVD Host Pool
├── appgroup.bicep           # Application Group
├── workspace.bicep          # Workspace
├── loganalytics.bicep       # Log Analytics Workspace
├── sessionhosts.bicep       # Deploys AVD session hosts
├── vm-deploy-loop.bicep     # Iterates VM creation based on count
├── InstallAvdAgent.ps1      # Script executed by session hosts
├── azure-pipelines.yml      # Full CI/CD pipeline with Azure DevOps
├── parameters.infra.dev.json # Infra parameters (DEV example)
└── parameters.vms.dev.json   # Session Host parameters (DEV example)
```

---

## 🛠 How It Works

### 🔹 Stage 1: Deploy Core AVD Infrastructure

- Host Pool, App Group, Workspace
- Tags and naming conventions are dynamically built
- AVD registration token is generated and stored in Azure Key Vault

### 🔹 Stage 2: Deploy AVD Session Hosts

- VM deployment with Trusted Launch and Gen2 images
- Domain join and OU placement
- Registers automatically to the Host Pool using the token from Key Vault

---

## ⚙️ Parameters

Two example files are included:

- `parameters.infra.dev.json`: Core infra deployment
- `parameters.vms.dev.json`: Session host deployment

Secrets are securely fetched from Azure Key Vault, including:

- `vmAdminPassword`
- `domainJoinPassword`
- `AVD registration token`

---

## ✅ Prerequisites

- Azure subscription with access to create resources
- Existing VNet/Subnet and domain controller integration
- Azure DevOps Service Connection configured
- Azure Key Vault with necessary secrets

---

## 📋 Usage

1. Update `azure-pipelines.yml` with your values (Key Vault, domain info, VNet)
2. Customize the parameter files as needed
3. Run the pipeline manually in Azure DevOps

---

## 🔐 Security Practices

- No hardcoded passwords or tokens
- Key Vault used for sensitive values
- Outputs parsed securely using `jq`

---

## ✍️ Author

**Harry Federico Argote Carrasco**  
Senior Cloud Engineer | Azure Specialist  
📍 Bella Vista, Buenos Aires, Argentina

> Feel free to fork this project or contribute improvements via PR.
