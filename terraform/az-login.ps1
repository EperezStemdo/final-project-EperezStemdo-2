az login

# Gets the suscription's data
$suscription_name = 'sandbox'
$suscription = az account list --query "[?name=='$suscription_name'].{tenantId:tenantId, id:id}" -o=json | ConvertFrom-Json

# Sets suscription to use
az account set --subscription $suscription.id

# Finds existing service principal
$sp_displayname = 'sp-eperez-dvfinlab-01'
$sp_appId = az ad sp list --filter "displayName eq '$sp_displayname'" --query "[].{id: appId}" -o=tsv
$akv_name = 'akv-eperez-dvfinlab'
$akv_secret_name = 'sp-eperez-dvfinlab-01'
$sp_pwd= az keyvault secret show --vault-name $akv_name --name $akv_secret_name --query "value" -o=tsv

#Sets temporary environment variables
$env:ARM_CLIENT_ID = $sp_appId
$env:ARM_CLIENT_SECRET = $sp_pwd
$env:ARM_SUBSCRIPTION_ID = $suscription.id
$env:ARM_TENANT_ID = $suscription.tenantId