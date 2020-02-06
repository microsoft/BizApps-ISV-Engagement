#$rootDirectory = $PSScriptRoot
#$baseDirectory = Split-Path -Path (Split-Path -Path (Split-Path -Path $rootDirectory -Parent))
$TotalNoOfInstancesAllowed = 12
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
$SourceInstanceOrganizationId = $Instancedetails.SourceInstanceOrganizationId
$TenantId = $Instancedetails.TenantId

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

Write-Output ("We would be deleting the following environments .....");    
$instanceno = 0;
$orgsTobeReset =""
for ($i = [int]$SuffixStart; $i -le $SuffixEnd; $i++) 
{
    $instanceno = $instanceno +1;        
    Write-Output ("$instanceno - Environment : $OrganizationFriendlyName$i");        
    $orgsTobeReset = "$OrganizationFriendlyName$i" + "|" + $orgsTobeReset
}

$arrOrg = $orgsTobeReset.split("|")

$ConfirmToProceed = Read-Host -Prompt "Do you want to continue resetting the above instances...type yes/no"    
if($ConfirmToProceed -notcontains "yes")
{    
    Write-Host "Invalid value passed..." -ForegroundColor Red
    return
}

#Write-Output ("Installing Xrm OnlineManagement APIs..");
#Install-Module -Name Microsoft.Xrm.OnlineManagementAPI -Force -Verbose -Scope CurrentUser

$Cred = Get-Credential;
$DeploymentRegion = "NorthAmerica"
$Error.Clear()

$CRMOrgs = Get-CrmOrganizations -Credential $Cred -DeploymentRegion $DeploymentRegion  -Confirm -OnLineType "Office365"

if ($Error.Count -gt 0) {
	$Error.Clear()
	write-host "An error occurred trying to login."
    return $false
}

$OrgsTobeReset = $CRMOrgs | Where-Object { $_.FriendlyName -in $arrOrg }
ForEach ($Org in $OrgsTobeReset) {
    
	Write-Host "FriendlyName: " $Org.FriendlyName
	Write-Host "UniqueName: " $Org.UniqueName
	Write-Host "Url: " $Org.WebApplicationUrl
	Write-Host ""

    
    $friendlyName = $Org.FriendlyName
    $TargetInstanceId = $Org.OrganizationId
    
    
    Write-Host "=================================Start deleting the instance $friendlyName =========================================" -ForegroundColor Green;
    Write-Host "============================================================================================================================" -ForegroundColor Green;
    Write-Output ("Sending request to deleting the organization {$friendlyName} please wait...");
    Write-Output ("Deleting instance started at: " + (Get-Date -format  yyyy-MM-dd-HH:mm:ss));

    $request = Remove-CrmInstance -ApiUrl $InstanceHostByRegion -Credential $Cred -TenantId $TenantId -Id $TargetInstanceId -MaxCrmConnectionTimeOutMinutes $TimeoutInMinutes -NonInteractive
        
    if ($request.Status -eq "FailedToCreate")
    {
        Write-Host "Delete request exited with errors ..." -ForegroundColor Red;
        Write-Host "Delete request completed with status: " + $request.Status -ForegroundColor Red;                
        break;
    }
    else
    {
        if ($request.Status -eq "Succeeded")
        {            
            Write-Output ("Delete request completed with status: " + $request.Status);                        
            Write-Output ("Dynamics 365 Instance {$friendlyName} deleted successfully...");            
        }
        else {
            Start-Sleep -s $sleepIntervalInSeconds
            $operation = Get-CrmOperationStatus -Id $request.OperationId -ApiUrl $InstanceHostByRegion -Credential $Cred
            Write-Output ("Waiting for delete request (" + $request.OperationId + ") to complete. Status is " + $operation.Status + "..");
            #$requestCompleted = ($operation.Status -eq "Succeeded");
            Write-Output ("Deleting request is running with status: " + $request.Status);
            Write-Output ("Proceeding to delete next instance ...");            
        }
    }
    Write-Host "===========================================================================" -ForegroundColor Green;
    Write-Host "=================================End=========================================" -ForegroundColor Green;
    Write-Host "*************************************************************************************************"
}