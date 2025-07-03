#!/bin/bash
Subscription_Name=""
AppRegistration=""
OfferType="MS-AZR-0148P"


az account create --offer-type "$OfferType" --display-name "$Subscription_Name"


Subscription_Id=$(az account list --query "[?displayName==$Subscription_Name].id" -o tsv)
# ad - Manage Microsoft Entra ID (formerly known as Azure Active
# sp - service principal
# create-for-rbac - Create an application and its associated service principal
detail=$(az ad sp create-for-rbac --name "$AppRegistration" --role Owner --scopes "/subscriptions/$Subscription_Id")


echo $detail >> "../../private/access_key/service-principal.txt"