#!/bin/bash
secretId=""
versionStage=("AWSCURRENT" "AWSPENDING")


aws secretsmanager get-secret-value \
    --secret-id $secretId \
    --version-stage "${versionStage[0]}"
    