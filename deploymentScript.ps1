param([string] $PackageUri, [string] $SubscriptionId, [string] $ResourceGroupName, [string] $FunctionAppName, [string] $ObjectId, [string] $Scope)

$credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $env:AppId, (ConvertTo-SecureString $env:AppSecret -AsPlainText -Force)
Connect-AzAccount -ServicePrincipal -TenantId $env:TenantId -Credential $credential -Subscription $SubscriptionId

Invoke-WebRequest -Uri $PackageUri -OutFile functionPackage.zip

Publish-AzWebapp -ResourceGroupName $ResourceGroupName -Name $FunctionAppName -ArchivePath functionPackage.zip -Force

Remove-AzRoleAssignment -ObjectId $ObjectId -RoleDefinitionName Owner -Scope $Scope
  