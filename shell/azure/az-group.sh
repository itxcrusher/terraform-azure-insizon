#!/bin/bash
# Manage Azure Resource groups
# https://azuretracks.com/2021/04/current-azure-region-names-reference/
# https://www.appliedi.net/blog/azure-east-us-vs-east-us-2-whats-the-difference/
# Or az interactive -> az group create -l 
region=(eastus eastus2 centralus)


az group --help

# List azure resources group
echo "List azure resources group"
sleep 1
az group list