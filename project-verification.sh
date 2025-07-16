#!/bin/bash

echo "🔍 Starting CrusherX Project Goal Verification..."
echo "────────────────────────────────────────────────────" > project-verification.log
echo "🔎 Verification started: $(date)" >> project-verification.log
echo "" >> project-verification.log

outputs=$(terraform output -json)

log() {
  echo -e "$1" | tee -a project-verification.log
}

# Generic check for maps
verify_map() {
  title="$1"
  key="$2"
  url_prefix="$3"

  log "\n$title:"
  map_entries=$(echo "$outputs" | jq -r "try .[\"$key\"] | to_entries[]? | @base64" 2>/dev/null)

  if [[ -z "$map_entries" ]]; then
    log "❌ No entries found for $key"
    return
  fi

  echo "$map_entries" | while read -r entry; do
    kv=$(echo "$entry" | base64 --decode | jq -r '.key, .value')
    name=$(echo "$kv" | sed -n 1p)
    url=$(echo "$kv" | sed -n 2p)

    if [[ "$url_prefix" != "none" ]]; then
      full_url="$url_prefix$url"
      status=$(curl -s --head --max-time 5 "$full_url" | grep "200 OK")
      if [[ -n "$status" ]]; then
        log "✅ $name reachable → $full_url"
      else
        log "❌ $name NOT reachable → $full_url"
      fi
    else
      log "✅ $name → $url"
    fi
  done
}

# Generic check for flat lists
verify_list() {
  title="$1"
  key="$2"

  log "\n$title:"
  values=$(echo "$outputs" | jq -r ".[\"$key\"][]?" 2>/dev/null)

  if [[ -z "$values" ]]; then
    log "❌ No entries found for $key"
    return
  fi

  echo "$values" | while read -r item; do
    log "✅ $item"
  done
}

# Entra Users
log "\n🧑‍💼 Microsoft Entra ID Users:"
users=$(echo "$outputs" | jq -r '.entra_created_users // {} | to_entries[]? | "✅ \(.key): \(.value)"')
[[ -n "$users" ]] && echo "$users" | tee -a project-verification.log || log "❌ No Entra users found"

# All web apps
verify_map "🌐 Web Apps" "webapp_urls" "https://"

# Custom domains
verify_map "🌍 Web App Custom Domains" "webapp_custom_domains" "https://"

# Function apps
verify_map "⚙️ Function Apps" "function_app_urls" "https://"

# Function app insights
verify_map "📊 App Insights (Function Apps)" "function_app_insights" "none"

# Key vaults
verify_map "🔐 Key Vault URIs" "key_vault_uris" "https://"

# Key vault secrets (just counts)
log "\n🔑 Key Vault Secrets:"
secrets=$(echo "$outputs" | jq -r '.key_vault_secrets | to_entries[]? | "\(.key): \(.value | length) secrets"' 2>/dev/null)
[[ -n "$secrets" ]] && echo "$secrets" | tee -a project-verification.log || log "❌ No secrets found"

# Storage accounts
verify_map "🗃️ Static Website Endpoints" "static_website_endpoints" "none"

# Service Bus
verify_list "🧵 Service Bus Namespaces (dev)" "service_bus_namespaces.dev"
verify_list "📬 Queues (dev)" "service_bus_queues.dev"
verify_list "📡 Topics (dev)" "service_bus_topics.dev"

# Redis (if any)
log "\n📦 Redis:"
redis=$(echo "$outputs" | jq -r '.redis_hostname? // empty')
[[ -n "$redis" ]] && log "✅ Redis: $redis" || log "ℹ️ Redis not deployed"

# Temp SPNs
log "\n🕓 Temporary Access SPNs:"
spn_file="private/entra_access_keys/devops-audit-7d.json"
[[ -f "$spn_file" ]] && log "✅ Found: $spn_file" || log "❌ Missing temp SPN creds"

# Databases
log "\n🧮 Databases:"
dbs=$(echo "$outputs" | jq -r '.databases | to_entries[]? | "\(.key): \(.value.name) (\(.value.type))"' 2>/dev/null)
[[ -n "$dbs" ]] && echo "$dbs" | tee -a project-verification.log || log "❌ No databases found"

# Logic App
log "\n🧩 Logic Apps:"
logic=$(echo "$outputs" | jq -r '.logic_app_id? // empty')
[[ -n "$logic" ]] && log "✅ Logic App ID: $logic" || log "ℹ️ Logic App not created"

# Done
log "\n🎯 CrusherX Verification Complete."
log "📄 Report saved to: project-verification.log"
