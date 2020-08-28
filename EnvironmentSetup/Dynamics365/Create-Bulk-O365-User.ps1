# # Import and Install MSOnline Module on Client Machine    
#Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass

#Connect-AzureAD
#Install-Module -Name AzureAD -Force -Verbose -Scope CurrentUser


#Install-Module -Name MSOnline -Force -Verbose -Scope CurrentUser
# Import-Module -Name MSOnline -ErrorAction SilentlyContinue -Force


#Connect-MsolService -Credential $credential
#Connect-AzureAD -Confirm
Connect-AzureAD


$userSequenceNoStart = 1;
$userSequenceNoEnd = 20;

$orgUserPassword = ""
#$userArray = @()
$UserDomainName = "@PowerPlatformOpenHacks.onmicrosoft.com"
$UserFirstName = "Coach"


for($i = $userSequenceNoStart; $i -le $userSequenceNoEnd; $i++)
{           
    ############### User Creation################################
    ############### User Creation################################

    Write-Output("Creating user with display name " + "$UserFirstName$i");        
    $userUPN="$UserFirstName$i$UserDomainName"

    $password = New-Object "Microsoft.Open.AzureAD.Model.PasswordProfile"
    $password.ForceChangePasswordNextLogin = $False
    $password.Password = $orgUserPassword
    $newUser = New-AzureADUser -DisplayName "$UserFirstName $i" -PasswordProfile $password -UserPrincipalName $userUPN -AccountEnabled $true -UsageLocation US -MailNickName "NotSet" -GivenName $UserFirstName -Surname "$i"
                    
    Write-Host "Object Id of created users " $newUser.ObjectId  
    Write-Output("User with display name " + $userUPN + "successfully created....");  
    
    ############### License Assignement ################################
    ############### License Assignement ################################
    Write-Output("**********************************************************")
    Write-Output("Assigning licenses to user " + "$UserFirstName$i$UserDomainName");

    
    $planName= "ENTERPRISEPACK","FLOW_FREE","POWER_BI_STANDARD","DYN365_ENTERPRISE_PLAN1"  

    $License = New-Object -TypeName Microsoft.Open.AzureAD.Model.AssignedLicense
    $SkuIds = (Get-AzureADSubscribedSku | Where-Object { $_.SkuPartNumber -in $planName }).SkuID
    $SkuIds = $SkuIds.split(' ')
    
    ForEach ($SkuId in $SkuIds) 
    {
        $License.SkuId = $SkuId
        #$License.SkuId = (Get-AzureADSubscribedSku | Where-Object { -Property SkuPartNumber -Value $planName -EQ}).SkuID
        $LicensesToAssign = New-Object -TypeName Microsoft.Open.AzureAD.Model.AssignedLicenses
        $LicensesToAssign.AddLicenses = $License
        Set-AzureADUserLicense  -ObjectId $userUPN -AssignedLicenses $LicensesToAssign

        Write-Output("Assigned license [$SkuId] to user " + "$userUPN");
    }


    ############### Admin Role Assignment################################
    ############### Admin Role Assignment################################
    
    Write-Output("**********************************************************")

    $roleName="CRM Service Administrator"   
    
    Write-Output("Assigning [Dynamics 365 Admin Role] to user " + $userUPN);

    $role = Get-AzureADDirectoryRole | Where-Object {$_.displayName -eq $roleName}

    if ($null -eq $role)
    {
        $roleTemplate = Get-AzureADDirectoryRoleTemplate | Where-Object {$_.displayName -eq $roleName}
        Enable-AzureADDirectoryRole -RoleTemplateId $roleTemplate.ObjectId
        $role = Get-AzureADDirectoryRole | Where-Object {$_.displayName -eq $roleName}
    }
    Add-AzureADDirectoryRoleMember -ObjectId $role.ObjectId -RefObjectId (Get-AzureADUser | Where-Object {$_.UserPrincipalName -eq $userUPN}).ObjectID
   
    Write-Output("[Dynamics 365 Admin Role] assigned to user " + $userUPN +  " successfully...");
    Write-Output("**********************************************************")
    #$userArray = $userArray + $newUser

} 