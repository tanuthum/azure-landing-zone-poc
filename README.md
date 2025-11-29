# Azure Landing Zone & Web App POC

## 1. Project Overview
This project implements a secure **Azure Landing Zone** using **Infrastructure as Code (Terraform)**. It demonstrates how to deploy a public-facing web application (Python Flask) while adhering to security best practices using Virtual Networks (VNet) and Subnet Delegation.

**Key Features:**
* **Infrastructure as Code:** 100% defined in Terraform.
* **Network Isolation:** Application runs inside a private VNet.
* **PaaS Integration:** Uses VNet Injection for Azure App Service.
* **Security:** Traffic flow controlled via Network Security Groups (NSGs).

---

## 2. Reference Architecture
Below is the logical architecture of the Landing Zone:

```mermaid
graph TB
    User([Internet User]) -->|HTTP:80| LB[Load Balancer]
    
    subgraph Azure["☁️ Azure Cloud - Southeast Asia"]
        direction TB
        
        subgraph RG["📦 Resource Group: rg-landing-zone-poc"]
            direction TB
            
            subgraph VNet["🌐 Virtual Network<br/>10.0.0.0/16"]
                direction TB
                
                subgraph Subnet["🔒 Workload Subnet<br/>10.0.1.0/24"]
                    direction LR
                    NSG["🛡️ Network Security Group<br/>Allow: HTTP (80)"]
                    AppService["🐍 App Service<br/>Python/Flask"]
                end
                
                VNetInt["VNet Integration"]
            end
            
            Monitor["📊 Monitoring & Logs"]
        end
    end
    
    LB -->|Routes Traffic| AppService
    AppService -.->|Integrated| VNetInt
    VNetInt -.->|Connected| Subnet
    AppService -.->|Logs & Metrics| Monitor
    NSG -->|Protects| AppService
    
    classDef userStyle fill:#34495e,stroke:#2c3e50,stroke-width:3px,color:#fff
    classDef azureStyle fill:#0078d4,stroke:#005a9e,stroke-width:2px,color:#fff
    classDef rgStyle fill:#50e6ff,stroke:#0078d4,stroke-width:2px,color:#000
    classDef vnetStyle fill:#d4f1ff,stroke:#0078d4,stroke-width:2px,color:#000
    classDef subnetStyle fill:#fff,stroke:#0078d4,stroke-width:2px,color:#000
    classDef resourceStyle fill:#7fba00,stroke:#5a8700,stroke-width:2px,color:#fff
    classDef securityStyle fill:#ff6b6b,stroke:#c92a2a,stroke-width:2px,color:#fff
    
    class User userStyle
    class Azure azureStyle
    class RG rgStyle
    class VNet vnetStyle
    class Subnet subnetStyle
    class AppService,Monitor resourceStyle
    class NSG securityStyle
```

**Note:** For this POC cost-optimization, the Load Balancer and Monitoring components are visualized here as part of the reference design but are not currently deployed in the Terraform script."

## 3. Technology Stack
* **Cloud Provider:** Microsoft Azure
* **IaC:** Terraform
* **Application:** Python 3.9 (Flask)
* **Scripting:** Bash / Azure CLI

## 4. How to Deploy
**Prerequisites**
* **Azure CLI installed**
* **Terraform installed**

**Steps**
**1. Clone  the Repo**
```
git clone [https://github.com/](https://github.com/)<YOUR_USERNAME>azure-landing-zone-poc.git
cd azure-landing-zone-poc
```
**2. Infrastructure Deployment:**
```
terraform init
terraform plan
terraform apply
```
**3. Application Deployment**
```
cd app
zip -r app.zip .
az webapp deploy --resource-group rg-landing-zone-poc --name <YOUR_APP_NAME> --src-path app.zip --type zip
```

## 5. Architectural Decisions
| Component | Decision | Justification |
| ---- | ---- | --- |
| B1 Service Plan  | Basic Tier | The B1 SKU is the minimum tier required to support VNet Integration, allowing the PaaS app to communicate securely within the VNet.|
| Subnet Delegation  | Microsoft.Web/serverFarms  | Required to "inject" the App Service into the Virtual Network subnet.|
| Terraform State | Local | For this POC, state is stored locally. In production, this would be moved to Azure Storage Account for team collaboration. |
