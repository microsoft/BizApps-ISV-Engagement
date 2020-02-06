# Dynamics 365 Environment setup

## Pre-requisites :
  *	[Install Management API](https://www.powershellgallery.com/packages/Microsoft.Xrm.OnlineManagementAPI/1.1.0.9060)

#### Update EnvironmentConfig.xml

![Update Configfile EnvironmentConfig.xml](https://github.com/microsoft/BizApps-ISV-Engagement/tree/master/Images/EnvironmentSetup/ConfigFile.png)

	TenantId - Please provide the tenantid where dynamics 365 environment/instance needs to be created.
	OrganizationFriendlyName - Please provide the OrganizationFriendlyName as this would be your organization name.

## Create Dynamics 365 Environments

  *	Download EnvironmentSetup folder
  * Open Powershell and locate navigate to "CreateEnvironment-For-Dynamics365.ps1"
  * Run CreateEnvironment-For-Dynamics365.ps1

![CreateEnvironment-For-Dynamics365](https://github.com/microsoft/BizApps-ISV-Engagement/tree/master/Images/EnvironmentSetup/Run-Create-Dynamics365-Environment.png)
  