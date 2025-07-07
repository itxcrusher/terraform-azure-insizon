# Project Goals


## Note
Feel free to change folder names and etc to make everything make more sense


## Create Microsoft EntraId 
0. Read from yaml file
1. Create Microsfot EntraId or Azure Active Directory user roles / IAM policy
similar to how the IAM user roles for the terraform AWS project
2. Roles - Admin, Developer, Service Account, ReadOnly
3. Add the feature where you can limit a user to a specific app/resource group
4. Must read from yaml file similar to terraform aws project with there properties
userName: service-bot
    fullName: Service Bot
    roles: [serviceAccount]
    limit: ["test-app"]



## Update Web App module
Note - App Insights, CreateLogicApp should be optional. If false this resource should be deleted
0. Read from yaml file
1. Figure out how to get the azurerm_app_service_source_control for private repo using classic access token
2. Create module for PostgresSQL and Azure SQL where one module of the modules will 
be ran if a specific property from yaml is found. Database should be one database added to resource group. Also, should Use both SQL and Microsoft Entra authentication
3. Each resource group should have keyvault. User should be able to view Key, Secret, Certificate
4. Each resource group should have a storage account should a type array for 
multiple storage account capibility in single resource group. Also, should be able to block all public access and only access via Azure CDN profile
5. Each account should have Application Insights
With create create_service: boolean
6. Figure out how to add custom domain name
7. Add module to create basic logic app for workflows.
8. Should have ability to limit user to specific resource group
Ex. web-app.yaml
apps:
  - Name:  insizon-app
    Env:   dev
    KeyVaultName: dev-key-group
    CreateAppInsight: true
    CreateLogicApp: true
    Github: 
      repoUrl: ""
      token: ""
      otherProperties...
    CustomDomain
      URL: ""
      otherProperties...
    StorageAccount:
      - storage1
      - storage2
    Database
      Type: PostgresSQL
      ServerAdminLogin: ""
      Password: ""
      otherProperties...




## Create Azure Service Bus
0. Read from yaml file
1. All four Azure services buses should be placed in same resource group for each
environment (dev, qa, stage, prod)
2. Should have a seperate yaml file (azure-service-bus.yaml) with these property
  Name: test-app
  Env: dev
  Topics
    - topic1
        MaxTopicSize: 1
        MessageTimeToLive: "14 0 0 0"
        OtherProperies...
    - topic2
    - topic3
  Quences
    - Quence1
    - Quence2


## Create function app module
Note - App Insights, CreateLogicApp should be optional. If false this resource should be deleted
1. Should have it's own resource group with Application insights, Storage, 
2. Should have a seperate yaml file (azure-function-app.yaml) with these property
  Name: test-app
  Env: dev
  Function
    Type: Windows or Linux
    HostingOptions: Flex Consumption, Consumption, App Service, etc
  CreateAppInsight: true
  CreateLogicApp: true
3. Create github workflow where I can deploy function app
Define the workflow:
The workflow should include steps for:
Checkout: Checking out your code from the repository. 
Azure Login: Authenticating with your Azure subscription using a service principal or managed identity. 
Azure Functions Action: Use the official Azure/functions-action to deploy the function app. 
Setting Deployment Source: Configure the deployment source as your GitHub repository. 


## Create Storage account for static files (similar to terraform aws project)
0. Read from yaml file
0. Should create a folder public folder that will hold static files
1. Upload folder files with folder based on yaml file. (Basically if FolderName property is not empty search for this )
2. Create module that creates bucket named insizon-static-bucket
3. This module will read from (static-files.yaml) and will have 
properties like 
FolderName
FilesExcluded
  - file2.txt
  - file2.txt
  - photo.img
that will create folder subfolder base on yaml property FolderName and will add all files. Unless the FileExcluded property is found and will avoid adding those files to subfolder bucket


## Project Additional


## For section Upate App Module
1. Add app registration - Need for app to work propertly / communication with Azure API?
2. Azure Cache for Redis
In yaml file should be able to create_service: boolean
to add Azure Cache for Redis
Yaml should include additional property to config redis to project specification


## Add Temporary Access module 
1. Must read from seperate yaml file then user.yaml
2. Will give users / contractor temporary access to perform their changes (Basically, anything you would have needed access too, to perform project)
yaml should have properties such
daysUntilExpire
...other
4. Should write these properties to file
-- client_id (App registration ID)
-- client_secret (Client secret from App registration)
-- tenant_id (Azure AD Tenant ID)
-- subscription_id (Azure Subscription ID)
-- any other properties needed by contractor (May access to login into Azure portal?)
