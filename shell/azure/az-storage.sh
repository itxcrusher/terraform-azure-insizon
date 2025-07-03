#!/bin/bash
# An Azure storage account is a container within Azure for storing and managing various types of data, 
# including blobs (unstructured data), files, queues, and tables. It provides a unique namespace for your data,
# accessible from anywhere in the world over HTTP or HTTPS. The data within a storage account is designed to be durable, highly available, secure, and scalable




az storage -h



# List storage accounts.
echo "List storage accounts"
sleep 1
az storage account list