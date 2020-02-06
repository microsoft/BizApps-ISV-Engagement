#$rootDirectory = $PSScriptRoot
#$baseDirectory = Split-Path -Path (Split-Path -Path (Split-Path -Path $rootDirectory -Parent))
$TotalNoOfInstancesAllowed = 15
$sleepIntervalInSeconds = 15
$EnvironmentConfig = "EnvironmentConfig.xml"
$EnvironmentConfigFile = Join-Path $PSScriptRoot $EnvironmentConfig
[xml]$xmldocument = Get-Content $EnvironmentConfigFile

$Instancedetails = $xmldocument.EnvironmentConfig.Environment.Dynammics365Instance
$OrganizationFriendlyName = $Instancedetails.OrganizationFriendlyName
$SuffixStart = $Instancedetails.SuffixStart
$SuffixEnd = $Instancedetails.SuffixEnd
$TimeoutInMinutes = $Instancedetails.TimeoutInMinutes
$InstanceType = $Instancedetails.InstanceType
$CopyType = $Instancedetails.CopyType
$InstanceHostByRegion = $Instancedetails.InstanceHostByRegion
$DefaultAppsTobeInstalled = $Instancedetails.DefaultAppsTobeInstalled


$TotalNoOfInstances = $SuffixEnd - $SuffixStart

Write-Output ("Organization name is: $OrganizationFriendlyName");
Write-Output ("Host is: $InstanceHostByRegion");
Write-Output ("Timeout is: $TimeoutInMinutes");

Write-Output ("Total no. of instances to be created : $TotalNoOfInstances");
Write-Output ("Total no. of instances allowed to be created : $TotalNoOfInstancesAllowed");

if($TotalNoOfInstances -ge $TotalNoOfInstancesAllowed)
{
    Write-Output ("Totla no. of intances $TotalNoOfInstances exceeded the max allowed intances: $TotalNoOfInstancesAllowed");    
    return;    
}

Write-Output ("We would be creating the following environments .....");    
$instanceno = 0;
for ($i = [int]$SuffixStart; $i -le $SuffixEnd; $i++) 
{
    $instanceno = $instanceno +1;        
    Write-Output ("$instanceno - Environment : $OrganizationFriendlyName$i");    
}

$ConfirmToProceed = Read-Host -Prompt "Do you want to continue creating the above instances...type yes/no"    
if($ConfirmToProceed -notcontains "yes")
{    
    Write-Host "Invalid value passed..." -ForegroundColor Red
    return
}

#Write-Output ("Installing Xrm OnlineManagement APIs..");
#Install-Module -Name Microsoft.Xrm.OnlineManagementAPI -Force -Verbose -Scope CurrentUser

try {
    $Cred = Get-Credential;
    $services = Get-CrmServiceVersions -ApiUrl $InstanceHostByRegion -Credential $Cred -MaxCrmConnectionTimeOutMinutes $TimeoutInMinutes
    $serviceVersion90 = $services | Where-Object { $_.Version -eq "9.0" }
}
catch {
    Write-Host "Invalid credentials" -ForegroundColor Red;
    return;
}


for ($i = [int]$SuffixStart; $i -le $SuffixEnd; $i++) 
{    
    
    $instanceFriendlyName =  $OrganizationFriendlyName + $i

    
    Write-Host "=================================Start provisioning instance $instanceFriendlyName =========================================" -ForegroundColor Green;
    Write-Host "============================================================================================================================" -ForegroundColor Green;
    Write-Output ("Sending request to provision new organization {$instanceFriendlyName} please wait...");
    Write-Output ("Provisioning started at: " + (Get-Date -format  yyyy-MM-dd-HH:mm:ss));

    if($DefaultAppsTobeInstalled -eq "")
    {
        $newCrmInstance = New-CrmInstanceInfo  -BaseLanguage 1033 -DomainName $instanceFriendlyName  -FriendlyName $instanceFriendlyName -InitialUserEmail $Cred.UserName -InstanceType $InstanceType -ServiceVersionId $serviceVersion90.Id -CurrencyCode 840 -CurrencyName USD -CurrencyPrecision 2 -CurrencySymbol $ -Purpose "OpenHack Instances"
    }
    else {
        $newCrmInstance = New-CrmInstanceInfo  -BaseLanguage 1033 -DomainName $instanceFriendlyName  -FriendlyName $instanceFriendlyName -InitialUserEmail $Cred.UserName -InstanceType $InstanceType -ServiceVersionId $serviceVersion90.Id -CurrencyCode 840 -CurrencyName USD -CurrencyPrecision 2 -CurrencySymbol $ -Purpose "OpenHack Instances" -TemplateList $DefaultAppsTobeInstalled
    }
    
    $request = New-CrmInstance -ApiUrl $InstanceHostByRegion -NewInstanceInfo $newCrmInstance -Credential $Cred  -MaxCrmConnectionTimeOutMinutes $TimeoutInMinutes

    if ($request.Status -eq "FailedToCreate")
    {
        Write-Host "Provisioning request exited with errors ..." -ForegroundColor Red;
        Write-Host "Provisioning request completed with status: " + $request.Status -ForegroundColor Red;                
        break;
    }
    else
    {
        if ($request.Status -eq "Succeeded")
        {            
            Write-Output ("Provisioning request completed with status: " + $request.Status);                        
            Write-Output ("Dynamics 365 Instance {$instanceFriendlyName} provisioned successfully...");            
        }
        else {
            Start-Sleep -s $sleepIntervalInSeconds
            $operation = Get-CrmOperationStatus -Id $request.OperationId -ApiUrl $InstanceHostByRegion -Credential $cred
            Write-Output ("Waiting for provisioning request (" + $request.OperationId + ") to complete. Status is " + $operation.Status + "..");
            #$requestCompleted = ($operation.Status -eq "Succeeded");
            Write-Output ("Provisioning request is running with status: " + $request.Status);
            Write-Output ("Proceeding to provisioning next instance ...");
        }
    }
    Write-Host "===========================================================================" -ForegroundColor Green;
    Write-Host "=================================End=========================================" -ForegroundColor Green;
    Write-Host "*************************************************************************************************"
}