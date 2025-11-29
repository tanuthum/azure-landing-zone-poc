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
graph TD
    User((Internet User)) -->|HTTP:80| AppService
    
    subgraph Azure Cloud ["Azure Cloud (East US)"]
        style Azure Cloud fill:#e6f2ff,stroke:#0072C6
        
        subgraph RG ["Resource Group: rg-landing-zone-poc"]
            style RG fill:#ffffff,stroke:#666
            
            subgraph VNet ["Virtual Network (10.0.0.0/16)"]
                style VNet fill:#f0f0f0,stroke:#333,stroke-dasharray: 5 5
                
                subgraph Subnet ["Workload Subnet (10.0.1.0/24)"]
                    style Subnet fill:#d6eaff,stroke:#0072C6
                    
                    NSG["NSG: Allow HTTP"]
                    AppService["App Service (Python/Flask)"]
                end
            end
        end
    end

    AppService -.->|VNet Integration| Subnet