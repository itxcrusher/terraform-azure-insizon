#!/usr/bin/env bash
set -euo pipefail

echo "Resource group status:"
az group show -n insizon-app-dev-rg --query properties.provisioningState -o tsv

echo "Web app:"
az webapp show -n insizon-app-dev-web -g insizon-app-dev-rg --query state -o tsv
curl -s -o /dev/null -w '%{http_code}\n' https://insizon-app-dev-web.azurewebsites.net

echo "Key vault access:"
az keyvault secret list --vault-name insizon-appdevnbu9 >/dev/null && echo "✅ KV list ok"

echo "SQL servers in RG:"
az sql server list -g insizon-app-dev-rg -o table

echo "Function RG exists?"
az group exists -n insizon-trigger-dev-rg && echo "✅" || echo "❌  not yet"

echo "ServiceBus RG exists?"
az group exists -n insizon-bus-dev-rg && echo "✅" || echo "❌  not yet"
