#!/bin/bash
# Azure will select / create a subscription account if you don't have one already



# About to login through azure cli
echo "About to login through azure cli"
sleep 1

# Check if logged in
az account list > /dev/null 2>&1

# $? will be 0 if the previous command was successful (logged in), non-zero otherwise
if [ $? -eq 0 ]; then
  echo "Already logged in to Azure."
  sleep 1
else
  echo "Not logged in!"
  echo "About to log you in."
  sleep 1
  az login
fi