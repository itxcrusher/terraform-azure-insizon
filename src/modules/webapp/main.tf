###############################################################################
# Resource Group & Plan
###############################################################################
resource "azurerm_resource_group" "main" {
  name     = "${local.app_name}-rg"
  location = local.location
  tags     = local.tags
}

resource "azurerm_service_plan" "main" {
  name                = "${local.app_name}-plan"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  os_type             = title(local.os_type)
  sku_name            = local.sku_name
  tags                = local.tags
}

###############################################################################
# web app (Windows / Linux) resources
###############################################################################
resource "azurerm_windows_web_app" "main" {
  count               = local.os_type == "windows" ? 1 : 0
  name                = "${local.app_name}-web"
  location            = azurerm_service_plan.main.location
  resource_group_name = azurerm_resource_group.main.name
  service_plan_id     = azurerm_service_plan.main.id
  tags                = local.tags

  site_config {
    always_on = local.always_on_valid
    application_stack {
      dotnet_version = local.dotnet_ver
    }
  }

  app_settings = merge(
    local.enable_app_insights ? {
      "APPINSIGHTS_INSTRUMENTATIONKEY"        = local.app_insights_key
      "APPLICATIONINSIGHTS_CONNECTION_STRING" = local.app_insights_connection
    } : {},
    {
      "WEBSITE_RUN_FROM_PACKAGE" = "1"
    },
    {
      "AZURE_CLIENT_ID"     = var.client_id
      "AZURE_CLIENT_SECRET" = var.client_secret
    },
    {
      for idx, sa in var.webapp_object.StorageAccount :
      "STORAGE_${idx}_SAS" => data.azurerm_storage_account_sas.attached[sa].sas
    },
    local.use_cdn ? {
      # Inject the CDN URL as an env var when UseCDN = true
      "CDN_BASE_URL" = local.use_cdn ? "https://${local.app_name}-endpoint.azureedge.net" : ""
    } : {}
  )
}

resource "azurerm_linux_web_app" "main" {
  count               = local.os_type == "linux" ? 1 : 0
  name                = "${local.app_name}-web"
  location            = azurerm_service_plan.main.location
  resource_group_name = azurerm_resource_group.main.name
  service_plan_id     = azurerm_service_plan.main.id
  tags                = local.tags

  site_config {
    always_on = local.always_on_valid
    application_stack {
      node_version = local.os_type == "linux" && local.node_ver != "" ? local.node_ver : null
    }
  }

  app_settings = merge(
    # 1) Application Insights settings (if enabled)
    local.enable_app_insights ? {
      "APPINSIGHTS_INSTRUMENTATIONKEY"        = local.app_insights_key
      "APPLICATIONINSIGHTS_CONNECTION_STRING" = local.app_insights_connection
    } : {},

    # 2) Always run from package
    {
      "WEBSITE_RUN_FROM_PACKAGE" = "1"
    },

    # 3) Service principal credentials
    {
      "AZURE_CLIENT_ID"     = var.client_id
      "AZURE_CLIENT_SECRET" = var.client_secret
    },

    # 4) SAS tokens for each attached storage account
    {
      for idx, sa in var.webapp_object.StorageAccount :
      "STORAGE_${idx}_SAS" => data.azurerm_storage_account_sas.attached[sa].sas
    },

    # 5) CDN base URL—only when UseCDN is true
    local.use_cdn ? {
      "CDN_BASE_URL" = local.use_cdn ? "https://${local.app_name}-endpoint.azureedge.net" : ""
    } : {}
  )
}

###############################################################################
# Key Vault
###############################################################################
module "key_vault" {
  source = "../key_vault"

  keyvault_object = {
    AppName                    = var.webapp_object.Name
    AppEnvironment             = var.webapp_object.Env
    Rg_Location                = azurerm_resource_group.main.location
    Rg_Name                    = azurerm_resource_group.main.name
    TenantId                   = var.tenant_id
    ObjectId                   = var.webapp_object.ObjectId
    additional_principals      = try(var.webapp_object.additional_principals, [])
    log_analytics_workspace_id = var.law_id
  }
}

resource "azurerm_key_vault_secret" "app_client_id" {
  name         = "app-client-id"
  value        = var.client_id
  key_vault_id = module.key_vault.vault_id

  depends_on = [module.key_vault]
}

resource "azurerm_key_vault_secret" "app_client_secret" {
  name         = "app-client-secret"
  value        = var.client_secret
  key_vault_id = module.key_vault.vault_id

  depends_on = [module.key_vault]
}

# Grant cert‐rotation permissions when using a custom domain without Azure-managed cert
resource "azurerm_role_assignment" "kv_certificates_officer" {
  count = local.custom_domain_enabled && !local.use_managed_cert ? 1 : 0

  scope                = module.key_vault.vault_id
  principal_id         = var.webapp_object.ObjectId # service principal / SPN that needs cert access
  role_definition_name = "Key Vault Certificates Officer"
}

###############################################################################
# Redis
###############################################################################
module "redis_cache" {
  source = "../redis"
  count = (
    var.webapp_object.Redis != null &&
    try(var.webapp_object.Redis.create_service, false)
  ) ? 1 : 0

  create_service      = true
  name_prefix         = local.app_name
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  sku_name             = try(var.webapp_object.Redis.sku_name, "Basic")
  capacity             = try(var.webapp_object.Redis.capacity, 0)
  family               = try(var.webapp_object.Redis.family, "C")
  non_ssl_port_enabled = try(var.webapp_object.Redis.enable_non_ssl_port, false) # backward-compat
  tags                 = local.tags
}

# Optional: store Redis key in the vault
resource "azurerm_key_vault_secret" "redis_primary_key" {
  count        = length(module.redis_cache) == 1 ? 1 : 0
  name         = "redis-primary-key"
  value        = module.redis_cache[0].primary_key
  key_vault_id = module.key_vault.vault_id

  depends_on = [module.key_vault]
}

###############################################################################
# Database (optional, only when webapp_object.Database is provided)
###############################################################################
module "database" {
  source = "../database"
  count  = var.webapp_object.Database == null ? 0 : 1

  Database_object = merge({
    AppName        = var.webapp_object.Name
    AppEnvironment = var.webapp_object.Env
    Rg_Location    = azurerm_resource_group.main.location
    Rg_Name        = azurerm_resource_group.main.name
    ObjectId       = var.webapp_object.ObjectId
    TenantId       = var.tenant_id
  }, var.webapp_object.Database)
}

# Store DB connection string securely in Key Vault
resource "azurerm_key_vault_secret" "db_connection" {
  count        = length(module.database) == 1 ? 1 : 0
  name         = "db-connection-string"
  value        = module.database[0].connection_string
  key_vault_id = module.key_vault.vault_id

  depends_on = [module.database]
}

###############################################################################
# Storage Account
###############################################################################
resource "azurerm_storage_account" "attached" {
  for_each                        = { for sa in var.webapp_object.StorageAccount : sa => sa }
  name                            = substr(lower(each.key), 0, 24)
  location                        = azurerm_resource_group.main.location
  resource_group_name             = azurerm_resource_group.main.name
  account_tier                    = var.webapp_object.StorageConfig.Tier
  account_replication_type        = var.webapp_object.StorageConfig.Replication
  public_network_access_enabled   = var.webapp_object.StorageConfig.PublicAccess
  https_traffic_only_enabled      = var.webapp_object.StorageConfig.OnlyHttp
  allow_nested_items_to_be_public = var.webapp_object.StorageConfig.PublicNestedItems
  min_tls_version                 = var.webapp_object.StorageConfig.MinTLSVersion

  network_rules {
    default_action = "Deny"
    bypass         = ["AzureServices"]
  }

  tags = local.tags
}

data "azurerm_storage_account_sas" "attached" {
  for_each           = azurerm_storage_account.attached
  connection_string  = each.value.primary_connection_string

  https_only = true
  start      = formatdate("YYYY-MM-DD", timestamp())
  expiry     = formatdate("YYYY-MM-DD", timeadd(timestamp(), "${var.webapp_object.SasExpiryYears * 8760}h"))

  resource_types {
    service   = true
    container = true
    object    = true
  }

  services {
    blob  = true
    file  = true
    queue = false
    table = false
  }

  permissions {
    read    = true
    write   = false
    delete  = false
    list    = true
    add     = false
    create  = false
    update  = false
    process = false
    tag     = false
    filter  = false
  }
}

# Create CDN Profile and Endpoint (per app) if UseCDN = true
resource "azurerm_cdn_profile" "webapp_cdn" {
  count               = local.use_cdn ? 1 : 0
  name                = "${local.app_name}-cdn"
  resource_group_name = azurerm_resource_group.main.name
  location            = "global"
  sku                 = "Standard_Microsoft"
  tags                = local.tags
}

resource "azurerm_cdn_endpoint" "webapp_cdn_endpoint" {
  count               = local.use_cdn ? 1 : 0
  name                = "${local.app_name}-endpoint"
  profile_name        = azurerm_cdn_profile.webapp_cdn[0].name
  resource_group_name = azurerm_resource_group.main.name
  location            = "global"

  origin {
    name      = "blob-origin"
    host_name = trimsuffix(azurerm_storage_account.attached[var.webapp_object.StorageAccount[0]].primary_blob_endpoint, "/")
  }

  tags = local.tags

  depends_on = [azurerm_storage_account.attached]
}

###############################################################################
# Integration
###############################################################################
# App Insights
resource "azurerm_application_insights" "insights" {
  count               = local.enable_app_insights ? 1 : 0
  name                = "${local.app_name}-insights"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  application_type    = "web"
  tags                = local.tags
}

# Logic App (stub)
module "logic_app" {
  source              = "../logic_app"
  create_logic_app    = local.enable_logic_app
  name_prefix         = local.app_name
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  tags                = local.tags
}
