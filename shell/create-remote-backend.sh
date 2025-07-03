#!/bin/bash
# Bash script that will help with creating remote backend 

# The name of the resource group
Resource_Group_Name=""
# Storage_Account_Name = Similar to Aws S3
Storage_Account_Name=""
# Container_Name = The folder name
Container_Name=""

# Create resource group
echo "Create resource group"
sleep 1
az group create --name "$Resource_Group_Name" --location eastus
# s2d23247-8a3d-4323-ac1b-16323696dasd1c1
# Create storage account
echo "Create storage account"
sleep 1
az storage account create --resource-group "$Resource_Group_Name" --name "$Storage_Account_Name" --sku Standard_LRS --encryption-services blob

# Create blob container
echo "Create blob container"
sleep 1
az storage container create --name "$Container_Name" --account-name "$Storage_Account_Name"

#Get the storage access key and store it as an environment variable
Account_Key=$(az storage account keys list --resource-group "$Resource_Group_Name" --account-name "$Storage_Account_Name" --query '[0].value' -o tsv) 
Arm_Access_Key=$Account_Key

echo "$Arm_Access_Key"
echo "$Arm_Access_Key" > "../private/access_key/access_key.txt"