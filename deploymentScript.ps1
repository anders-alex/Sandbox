param([string] $PackageUri, [string] $SubscriptionId, [string] $ResourceGroupName, [string] $FunctionAppName, [string] $KeyVaultName, [string] $FAScope, [string] $KVScope, [string] $UAMIPrincipalId)

Set-AzContext -Subscription $SubscriptionId

#Download Function App package and publish.
Invoke-WebRequest -Uri $PackageUri -OutFile functionPackage.zip
Publish-AzWebapp -ResourceGroupName $ResourceGroupName -Name $FunctionAppName -ArchivePath functionPackage.zip -Force

#Get list of Function App outbound IPs so we can restrict network access on the Key Vault.
$functionAppIps = (Get-AzFunctionApp -ResourceGroupName $ResourceGroupName -Name $FunctionAppName).OutboundIPAddress.Split(',')

foreach ($ip in $functionAppIps) {
    Add-AzKeyVaultNetworkRule -VaultName $KeyVaultName -IpAddressRange $ip
}
Update-AzKeyVaultNetworkRuleSet -VaultName $KeyVaultName -DefaultAction Deny -Bypass None

#Cleanup the Service Principal Owner role assignments now that access is no longer needed.
Remove-AzRoleAssignment -ObjectId $ObjectId -RoleDefinitionName Owner -Scope $FAScope
Remove-AzRoleAssignment -ObjectId $ObjectId -RoleDefinitionName Owner -Scope $KVScope
  