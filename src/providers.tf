# Providers 
# providers.ts is the file where you list and configure your providers to be use. Ex Aws, Azure, Gcp
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.28.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "3.4.0"
    }
    random = {
      source = "hashicorp/random"
    }
  }
}

# Azure Subscription tab - Subscription_id
# Azure App Registrion tab (terraform-app-registration) - tenant_id, client_id, client_secret
# Azure App Registrion the process of registering an application with Microsoft Entra ID (formerly Azure Active Directory). This registration gives your application the necessary credentials to securely access Azure services and APIs.
provider "azurerm" {
  features {
    resource_group { prevent_deletion_if_contains_resources = false }
  }

  client_id       = var.client_id
  client_secret   = var.client_secret
  tenant_id       = var.tenant_id
  subscription_id = var.subscription_id
}

# Needed for Entra-ID (users / role-assignments)
provider "azuread" {
  tenant_id = var.tenant_id
}
