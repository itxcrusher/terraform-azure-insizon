#!/bin/bash
# Azure-cli is a command line tool used to help speed of the process of managing your azure resources
# without the need for you to login into online website portal and click buttons to create/manage resources
# You can also use the azure cloud shell
# https://formulae.brew.sh/formula/azure-cli



echo "About to install Azure cli"
sleep 1
brew install azure-cli

az --version
