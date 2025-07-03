#!/bin/bash



# About to logout and clear cache
echo "About to logout and clear cache"
sleep 1
az logout
az cache purge
az account clear  


echo "Done :)"