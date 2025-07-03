# WebApp
# https://www.youtube.com/watch?v=ZoB5cG_zakM





locals {
  # Location - https://azuretracks.com/2021/04/current-azure-region-names-reference/
  location = {
    Central_Us      = "centralus"
    East_US         = "eastus"
    East_US2        = "eastus2"
    SouthCentral_US = "southcentralus"
    West_US2        = "westus2"
    West_US3        = "westus3"
    West_US         = "westus"
    NorthCentral_US = "northcentralus"
  }
  OS_Types = {
    Windows          = "Windows"
    Linux            = "Linux"
    WindowsContainer = "WindowersContainer"
  }
  # Free_F1 - 0.00 USD/Month
  # Shared_D1 (Recommended) - 11.90 USD/Month
  # Basic_B1 - 60.59 USD/Month
  # Standard_S1 - 80.30 USD/Month
  # Premium_V3_POV3 - 119.72 USD/Month
  # Premium_V3_P1V3 - 239.44 USD/Month
  # Premium_V3_P1MV3 - 263.97 USD/Month
  WindowsOsType_Sku_Names = {
    Free_F1          = "F1"
    Shared_D1        = "D1"
    Basic_B1         = "B1"
    Standard_S1      = "S1"
    Premium_V3_POV3  = "P0v3"
    Premium_V3_P1V3  = "P1v3"
    Premium_V3_P1MV3 = "P1mV3"
  }
  # Free_F1 - 0.00 USD/Month
  # Basic_B1 - 13.14 USD/Month
  # Premium_V3_POV3 - 61.32 USD/Month
  # Premium_V3_P1V3 - 122.64 USD/Month
  # Premium_V3_P1MV3 - 147.17 USD
  LinuxOsType_Sku_Names = {
    Free_F1          = "F1"
    Basic_B1         = "B1"
    Premium_V3_POV3  = "POv3"
    Premium_V3_P1V3  = "P1v3"
    Premium_V3_P1MV3 = "P1mv3"
  }
  # https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/windows_web_app
  Application_Stack = {
    Dotnet_Version = {
      ASP_Net_V3dot5 = "v2.0"
      ASP_Net_V3dot5 = "v4.0"
      Net_6_LTS      = "v6.0"
      Net_7_STS      = "v7.0"
      Net_8_LTS      = "v8.0"
      Net_9_STS      = "v9.0"
    }
    Nodejs_Version = {
      Node_12 = "~12"
      Node_14 = "~14"
      Node_16 = "~16"
      Node_18 = "~18"
      Node_20 = "~20"
      Node_22 = "~22"
    }
    Python_Version = {
      IsPython = "cat"
    }
    Php_Version = {
      Php_7dot1 = "7.1"
      Php_7dot4 = "7.4"
    }
    Java_Version = {
      Java_10dot0      = "10.0"
      Java_10dot0dot20 = "10.0.20"
    }
  }
}



# Create the resource group
resource "azurerm_resource_group" "main" {
  name     = "${var.webapp_object.AppName}-resource-group"
  location = local.location.Central_Us
}


output "name" {
  value = local.Application_Stack.Dotnet_Version.Net_8_LTS
}

# Create the Linux App Service Plan
# The virtual machine (VM) that the app service is hosted on
resource "azurerm_service_plan" "main" {
  name                = "${var.webapp_object.AppName}-app-service-plan"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  os_type             = local.OS_Types.Windows
  sku_name            = local.WindowsOsType_Sku_Names.Shared_D1
}

# Create the web app, pass in the App Service Plan ID
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/windows_web_app
resource "azurerm_windows_web_app" "main" {
  name                = "${var.webapp_object.AppName}-dotnet-webapp"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_service_plan.main.location
  service_plan_id     = azurerm_service_plan.main.id
  depends_on          = [azurerm_service_plan.main]

  site_config {
    always_on = false
    application_stack {
      dotnet_version = local.Application_Stack.Dotnet_Version.Net_8_LTS
    }
  }
}

# private/note.md
# note no 01


#  Deploy code from a public GitHub repo
# resource "azurerm_app_service_source_control" "sourcecontrol" {
#   app_id                 = azurerm_windows_web_app.main.id
#   repo_url               = "https://github.com/insizon/insizonDotnet.git"
#   branch                 = split("-", var.AppName)[1]
#   use_manual_integration = true
#   use_mercurial          = false
# }



module "database_module" {
  source = "../database"

  Database_object = {
    AppName        = split("-", var.webapp_object.AppName)[0]
    AppEnvironment = split("-", var.webapp_object.AppName)[1]
    Rg_Location    = azurerm_resource_group.main.location
    Rg_Name        = azurerm_resource_group.main.name
  }
}


module "keyVault_module" {
  source = "../key_vault"

  keyvault_object = {
    AppName        = split("-", var.webapp_object.AppName)[0]
    AppEnvironment = split("-", var.webapp_object.AppName)[1]
    Rg_Location    = azurerm_resource_group.main.location
    Rg_Name        = azurerm_resource_group.main.name
    ObjectId       = var.webapp_object.ObjectId
    TenantId       = var.webapp_object.TenantId
  }
}