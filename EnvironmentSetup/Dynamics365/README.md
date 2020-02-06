# Dynamics 365 Environment setup : 
* Leverage this tools to Bulk create Dynamics 365 environments. 
* This tools also can be modifed to use it in AzureDevOps pipline.

## Pre-requisites :
  *	[Install Management API](https://www.powershellgallery.com/packages/Microsoft.Xrm.OnlineManagementAPI/1.1.0.9060)

#### Update EnvironmentConfig.xml

![](https://github.com/microsoft/BizApps-ISV-Engagement/blob/master/Images/EnvironmentSetup/ConfigFile.png)

	TenantId - Please provide the tenantid where dynamics 365 environment/instance needs to be created.
	OrganizationFriendlyName - Please provide the OrganizationFriendlyName as this would be your organization name.
	SuffixStart - This number will be appended with every OrganizationFriendlyName i.e SampleUserInstance+1001
	SuffixEnd - This number will be appended with every OrganizationFriendlyName i.e SampleUserInstance+1001
	SuffixStart and SuffixEnd would help to generate unique OrganizationFriendlyName i.e If SuffixStart is 100 and SuffixEnd is 105 then it will create 5 environments.

## Create Dynamics 365 Environments

  *	Download EnvironmentSetup folder
  * Open Powershell and locate navigate to "CreateEnvironment-For-Dynamics365.ps1"
  * Run CreateEnvironment-For-Dynamics365.ps1

![](https://github.com/microsoft/BizApps-ISV-Engagement/blob/master/Images/EnvironmentSetup/Run-Create-Dynamics365-Environment.png)  


## Delete Dynamics 365 Environments

  *	Download EnvironmentSetup folder
  * Open Powershell and locate navigate to "DeleteEnvironment-For-Dynamics365.ps1"
  * Run DeleteEnvironment-For-Dynamics365.ps1

![](https://github.com/microsoft/BizApps-ISV-Engagement/blob/master/Images/EnvironmentSetup/Run-Delete-Dynamics365-Environment.png)