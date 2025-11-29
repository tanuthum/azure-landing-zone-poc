# Configure the Azure Provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# 1. Resource Group
resource "azurerm_resource_group" "rg" {
  name     = "rg-landing-zone-poc"
  location = "Southeast Asia" # Change to a region near you
}

# 2. Virtual Network (The Foundation)
resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-landing-zone"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

# 3. Subnets (The Rooms)
resource "azurerm_subnet" "subnet_workload" {
  name                 = "snet-workload"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
  
  # Required for App Service VNet Integration
  delegation {
    name = "delegation"
    service_delegation {
      name    = "Microsoft.Web/serverFarms"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }
}

# 4. Network Security Group (The Firewall)
resource "azurerm_network_security_group" "nsg" {
  name                = "nsg-workload"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  # Security Rule: Allow HTTP traffic
  security_rule {
    name                       = "AllowHTTP"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Associate NSG with Subnet
resource "azurerm_subnet_network_security_group_association" "example" {
  subnet_id                 = azurerm_subnet.subnet_workload.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

# 5. App Service Plan (The Hardware Specs)
# Note: B1 is the lowest tier that supports VNet Integration usually.
# If using Free Tier (F1), remove the VNet integration blocks.
resource "azurerm_service_plan" "app_plan" {
  name                = "asp-landing-zone"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  os_type             = "Linux"
  sku_name            = "B1" 
}

# 6. App Service (The Application Container)
resource "azurerm_linux_web_app" "webapp" {
  name                = "app-landing-zone-poc-123" # MUST BE GLOBALLY UNIQUE. Change this!
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_service_plan.app_plan.location
  service_plan_id     = azurerm_service_plan.app_plan.id

  site_config {
    application_stack {
      python_version = "3.9"
    }
  }
}

# 7. VNet Integration (Connecting App to the Private Network)
resource "azurerm_app_service_virtual_network_swift_connection" "vnet_integration" {
  app_service_id = azurerm_linux_web_app.webapp.id
  subnet_id      = azurerm_subnet.subnet_workload.id
}

# Output the Web App URL
output "webapp_url" {
  value = azurerm_linux_web_app.webapp.default_hostname
}