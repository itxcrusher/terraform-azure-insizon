# Database








locals {
  # Recommended - Basic
  Database_Sku_names = {
    GP_S_Gen5_2 = "GP_S_Gen5_2"
    HS_Gen4_1   = "HS_Gen4_1"
    BC_Gen5_2   = "BC_Gen5_2"
    ElasticPool = "ElasticPool"
    Basic       = "Basic"
    S0          = "S0"
    P2          = "P2"
    DW100c      = "DW100c"
    DS100       = "DS100"
  }
  Databse_Enclave_Type = {
    Default = "Default"
    VBS     = "VBS"
  }
  # BasePrice - This value indicates that the Azure Hybrid Benefit (AHB) is being used. If you have existing SQL Server licenses, you can apply them to your Azure SQL Database and receive a discounted price.
  # LicenseIncluded (Recommended) - This value indicates that a new SQL Server license is being included with the Azure SQL Database. You won't need to provide your own license, but the pricing will reflect the cost of a new license. 
  Databse_LicenseType = {
    BasePrice       = "BasePrice"
    LicenseIncluded = "LicenseIncluded"
  }
}


resource "random_password" "admin_password" {
  length      = 20   # Adjust the length as needed
  special     = true # Include special characters
  min_numeric = 1    # Minimum number of numeric characters
  min_upper   = 1    # Minimum number of uppercase characters
  min_lower   = 1    # Minimum number of lowercase characters
  min_special = 1    # Minimum number of special characters
}


locals {
  admin_password = random_password.admin_password.result
}


resource "local_file" "main" {
  content  = "UserName: insizon-sql-admin, Password: ${local.admin_password}"
  filename = "${path.module}/../../../private/database_passwords/${var.Database_object.AppName}-${var.Database_object.AppEnvironment}-database-password.csv"
}


# Database Option 
# SQLAzure - TerraformName (azurerm_mssql_server)
# PostgreSQl - TerraformName ()
# MySQL - TerraformName ()
# Cosmos DB API for MongoDb - TerraformName ()
resource "azurerm_mssql_server" "main" {
  name                         = "${var.Database_object.AppName}-sql-server-engine"
  resource_group_name          = var.Database_object.Rg_Name
  location                     = var.Database_object.Rg_Location
  version                      = "12.0"
  administrator_login          = "insizon-sql-admin"
  administrator_login_password = local.admin_password

  # azuread_administrator {
  #   login_username = "AzureAD Admin"
  #   object_id      = "00000000-0000-0000-0000-000000000000"
  # }

  lifecycle {
    prevent_destroy = false
    ignore_changes  = [administrator_login_password]
  }
  tags = {
    environment = var.Database_object.AppEnvironment
  }
}



# collation - In Azure SQL Database, a collation is a set of rules that dictate how character data is compared and sorted.
# The default collation for Azure SQL Database is SQL_Latin1_General_CP1_CI_AS
# enclave_type - In Azure, enclave_type refers to the type of secure enclave used for Always Encrypted with secure enclaves. This feature enhances data confidentiality by isolating a region of memory within the database engine to securely process encrypted data
# license_type - In Azure databases, specifically Azure SQL Database, the license_type parameter determines whether Azure Hybrid Benefit (AHB) is used, influencing the pricing for existing SQL Server license owners.
resource "azurerm_mssql_database" "main" {
  name         = "${var.Database_object.AppName}-database"
  server_id    = azurerm_mssql_server.main.id
  collation    = "SQL_Latin1_General_CP1_CI_AS"
  license_type = local.Databse_LicenseType.LicenseIncluded
  max_size_gb  = 2
  sku_name     = local.Database_Sku_names.Basic
  enclave_type = local.Databse_Enclave_Type.Default

  tags = {
    environment = var.Database_object.AppEnvironment
  }

  # prevent the possibility of accidental data loss
  lifecycle {
    prevent_destroy = false
  }
}