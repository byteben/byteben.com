---
title: "Automatically Migrate Applications from ConfigMgr to Intune with the Win32App Migration Tool"
date: 2021-03-27
categories:
  - "ConfigMgr / MEMCM / SCCM"
  - "Intune"
  - "Microsoft"
  - "Scripts"
---

The **Win32App Migration Tool** is a free community tool that has been developed to do the scoping and heavy lifting for you as you consider building Win32apps in Intune while using your ConfigMgr apps as a reference. The tool is designed to inventory ConfigMgr Applications and Deployment Types, build .intunewin files and create Win32apps directly in the MEM admin center.

<!--more-->

## Table of Contents

- **[Background](#background)**
- [**Win32 App Migration Tool**](#Win32_App_Migration_Tool)
    - [Planned Development](#Win32_App_Migration_Tool_Planned_Development)
    - [Requirements](#Win32_App_Migration_Tool_Requirements)
    - [Installation](#Win32_App_Migration_Tool_Installation)
    - [**Working Directory**](#Win32_App_Migration_Tool_Working_Directory)
        - [Content](#Win32_App_Migration_Tool_Working_Directory_Content)
        - [ContentPrepTool](#Win32_App_Migration_Tool_Working_Directory_ContentPrepTool)
        - [Details](#Win32_App_Migration_Tool_Working_Directory_Details)
        - [Logos](#Win32_App_Migration_Tool_Working_Directory_Logos)
        - [Logs](#Win32_App_Migration_Tool_Working_Directory_Logs)
        - [Win32Apps](#Win32_App_Migration_Tool_Working_Directory_Win32Apps)
    - [**Using the Win32 App Migration Tool**](#Win32_App_Migration_Tool_Using_The_Win32_App_Migration_Tool)
        - [Parameters](#Win32_App_Migration_Tool_Using_The_Win32_App_Migration_Tool_Parameters)
        - **[Examples](#Win32_App_Migration_Tool_Using_The_Win32_App_Migration_Tool_Examples)**
            - [Basic Example](#Win32_App_Migration_Tool_Using_The_Win32_App_Migration_Tool_Examples_Basic_Example)
            - [Exporting Logos](#Win32_App_Migration_Tool_Using_The_Win32_App_Migration_Tool_Examples_Exporting_Logos)
            - [Reset the Log](#Win32_App_Migration_Tool_Using_The_Win32_App_Migration_Tool_Examples_Exporting_Reset_The_Log)
            - [Omit the Grid View](#Win32_App_Migration_Tool_Using_The_Win32_App_Migration_Tool_Examples_Exporting_Omit_The_Grid_View)
            - [Package Applications](#Win32_App_Migration_Tool_Using_The_Win32_App_Migration_Tool_Examples_Package_Applications)
    - [Versioning](#Win32_App_Migration_Tool_Versioning)
- **[Summary](#Summary)**

## Background

Microsoft Endpoint Manager (MEM) continues to grow from strength to strength. Having just recently marked its [10 year anniversary](https://twitter.com/dispensa/status/1374401646399082499?s=20), Intune, part of MEM, is now a real force to be reckoned with. Many companies are realising the value of modernising the way they manage their endpoints and MEM offers them an astonishing arsenal of options. Every company I work with has a slightly different approach to modern management and the line between "on-premise" and "cloud" has definitely been blurred with recent MEM developments.

Many endpoint administrators and solution experts have invested heavily in the Configuration Manager application model. It has been a robust solution to deploy applications to devices since before I can even remember so here comes the challenge...as I look to move more workloads to the cloud to support my internet based devices, can I take my applications, that I invested blood, sweat and tears over for all those years, with me? Sure. Many organisations are realising the value of Cloud Management Gateway (CMG). I can absolutely deploy a CMG and continue to deliver my ConfigMgr apps to my internet based devices without killing my VPN. But what if part of my modern management strategy is to move my applications into Intune too? Or what if I want to start testing my business application delivery from Intune? Dipping a toe in the proverbial water so to speak. Can I not just export my applications from ConfigMgr straight into Intune? Sadly, no.

Deploying Win32apps, from Intune, very closely resembles the application delivery method in ConfigMgr. Win32apps have install/uninstall commands, requirements, detection logic, dependencies and now even supersedence (preview feature). One main difference is that you have to use a tool to "package" the application for delivery. A high level overview of creating a Win32app, when referencing a ConfigMgr app, to deploy from Intune, is:-

1. Locate the source content directory for the ConfigMgr Application "Deployment Type"
2. Identify the "Setup File" for each Deployment Type e.g. "AdobeReader.msi" or "InstallMyApp.ps1"
3. Use the **Win32 Content Prep Tool** to take that information to create a .intunewin file
4. Create a Win32app in the MEM console, upload the .intunewin and specify the app details, a logo, install/uninstall commands, program behaviour, return codes, detection logic, requirements, dependencies and supersedence rules (preview). This information would have to be gathered, normally manually, from the ConfigMgr console.

Maurice Daly has a good blog post on how to deploy Win32apps - go and check it out to learn more  
[https://msendpointmgr.com/2018/09/24/deploy-win32-applications-with-microsoft-intune/](https://msendpointmgr.com/2018/09/24/deploy-win32-applications-with-microsoft-intune/)

## Win32App Migration Tool

The **Win32App Migration Tool** is a free community tool that has been developed to do the scoping and heavy lifting for you as you consider building Win32apps in Intune while using your ConfigMgr apps as a reference. The tool is designed to inventory ConfigMgr Applications and Deployment Types, build .intunewin files and create Win32apps directly in the MEM admin center. Instead of manually checking Application and Deployment Type information and gathering content to build Win32apps, the Win32App Migration Tool is designed to do that for you.

### Planned Development

The Win32App Migration Tool is still in development. This is a FREE community tool and will have input from various community members through each development stage. At the time of writing this post the tool is still in **BETA** with the intention to move rapidly to **RELEASE** and then **General Availability (GA)**. You can expect the following features at each release cycle: -

<figure>

[![](/images/2021/03/image-23-1024x722.png)](/images/2021/03/image-23.png)

<figcaption>

Win32 App Migration Tool Development Release Cycle

</figcaption>

</figure>

### Requirements

- **Configuration Manager Console** The ConfigMgr console must be installed on the machine you are running the Win32App Migration Tool from. The following path should resolve true: _$ENV:SMS\_ADMIN\_UI\_PATH_
- **Local Administrator** The default Working folder is %SystemDrive%\\Win32AppMigrationTool. You will need permissions to create this directory on the System Drive
- **Roles** Permission to run the Configuration Manager cmdlet Get-CMApplication \*
- **Content Folder Permission** Read permissions to the content source for the Deployment Types that will be exported
- **PowerShell** 5.1
- **.NET Framework** 4.7.2 to run the Win32 Content Prep Tool
- **NuGet Provider** 2.8.5.201 or newer
- **Internet Access** to download the Win32 Content Prep Tool

> \* Configuration cmdlets must be run from the Configuration Manager site drive. The Win32App Migration Tool will automatically make this connection.

### Installation

The Win32App Migration Tool is published in the PowerShell Gallery. You can install the module by running the command: -

```
Install-Module -Name Win32AppMigrationTool
```

<figure>

[![](/images/2021/03/image-2.png)](/images/2021/03/image-2.png)

<figcaption>

https://www.powershellgallery.com/packages/Win32AppMigrationTool

</figcaption>

</figure>

### Working Directory

The Win32App Migration Tool will build (and maintain) the following "Working Directory". The default directory created is **%SystemDrive%\\Win32AppMigrationTool**

<figure>

[![](/images/2021/03/image-1.png)](/images/2021/03/image-1.png)

<figcaption>

Win32App Migration Tool Folder Structure

</figcaption>

</figure>

#### Content

The Deployment Type content for the selected Application(s) will be copied to this folder. A folder will be created for each identified Deployment Type

<figure>

[![](/images/2021/03/image-3.png)](/images/2021/03/image-3.png)

<figcaption>

Win32App Migration Tool Content Folder

</figcaption>

</figure>

#### ContentPrepTool

The Win32 Content Prep Tool **IntuneWinAppUtil.exe** will be downloaded to this folder

<figure>

[![](/images/2021/03/image-4.png)](/images/2021/03/image-4.png)

<figcaption>

Win32App Migration Tool ContentPrepTool Folder

</figcaption>

</figure>

#### Details

During the **BETA** and **RELEASE** phase you will use the information gathered from ConfigMgr to build out the Win32apps in Intune manually. The information you will need is exported to 2 of the 3 CSV's in the Details folder. **Applications.csv** and **DeploymentTypes.csv**

<figure>

[![](/images/2021/03/image-5.png)](/images/2021/03/image-5.png)

<figcaption>

Win32App Migration Tool Details Folder

</figcaption>

</figure>

The information gathered in each CSV is as follows:-

##### **Applications**

Information about the Application(s) selected using the Win32App Migration Tool. This information can be used to build out the Win32app in Intune. _Application\_LogicalName_ is a link reference to _Application\_LogicalName_ in DeploymentType.csv

- Application\_LogicalName
- Application\_Name
- Application\_Description
- Application\_Publisher
- Application\_Version
- Application\_IconId
- Application\_TotalDeploymentTypes

##### **Content**

You can track where the content is downloaded for each Deployment Type. _Content\_DeploymentType\_LogicalName_ is a link reference to _DeploymentType\_LogicalName_ in DeploymentTypes.csv

- Content\_DeploymentType\_LogicalName
- Content\_Location

##### **DeploymentTypes**

Information specific to each deployment type for each Application(s) selected using the Win32App Migration Tool. This information can be used to build out the Win32app in Intune

- Application\_LogicalName
- DeploymentType\_LogicalName
- DeploymentType\_Name
- DeploymentType\_Technology
- DeploymentType\_ExecutionContext
- DeploymentType\_InstallContent
- DeploymentType\_InstallCommandLine
- DeploymentType\_UnInstallSetting
- DeploymentType\_UninstallContent
- DeploymentType\_UninstallCommandLine

#### Logos

Application Logos are exported to this folder

<figure>

[![](/images/2021/03/image-6.png)](/images/2021/03/image-6.png)

<figcaption>

Win32App Migration Tool Logos Folder

</figcaption>

</figure>

#### Logs

Detailed log information can be found in **Main.log**

<figure>

[![](/images/2021/03/image-7.png)](/images/2021/03/image-7.png)

<figcaption>

Win32App Migration Tool Logs Folder - **Main.log**

</figcaption>

</figure>

#### Win32Apps

.intunewin files are exported to _Win32Apps\\Application\_<GUID>\\DeploymentType\_<GUID>\\<setupfile>.intunewin_

<figure>

[![](/images/2021/03/image-8.png)](/images/2021/03/image-8.png)

<figcaption>

Win32App Migration Tool Win32Apps Folder

</figcaption>

</figure>

### Using the Win32 App Migration Tool

Once you have installed the module and observed the prerequisites you are ready to begin using the tool. During the **BETA** phase you will pass parameters to the Win32App Migration Tool in PowerShell. The command we run is **New-Win32App**. The following parameters are valid:-

#### Parameters

**.Parameter AppName** (Required)  
Pass an app name to search for any matching applications in ConfigMgr. You can use \* as a wildcard e.g. "Microsoft\*" or "\*Reader"

**.Parameter SiteCode** (Required)  
Specify the Sitecode you wish to connect to

**.Parameter ProviderMachineName** (Required)  
Specify the Site Server to connect to

**.Parameter ExportLogo**   
When passed, the Application logo is decoded from base64 and exported to the Logos folder

**.Parameter WorkingFolder** This is the working folder for the Win32AppMigration Tool. Care should be given when specifying the working folder because downloaded content can increase the working folder size considerably. The following folders are created in this directory:-

\-Content  
\-ContentPrepTool  
\-Details  
\-Logos  
\-Logs  
\-Win32Apps

**.Parameter PackageApps**  
Pass this parameter to package selected apps in the .intunewin format. The .Intunewin files will be saved in the %WorkingFolder%\\Win32Apps folder

**.Parameter CreateApps** (Not available in **BETA** or **RELEASE** development phases)  
Pass this parameter to create the Win32apps in Intune

**.Parameter ResetLog**  
Pass this parameter to reset the log file

**.Parameter NoOGV**  
Pass this parameter supress the Out-GridView for selecting Applications. You can still pass wildcards to the -AppName parameter

#### Examples

##### Basic Example

Using the required parameters, we can run the tool for the first time

```
New-Win32App -AppName "Microsoft*" -ProviderMachineName bb-cm1.byteben.com -SiteCode BB1
```

<figure>

[![](/images/2021/03/image-12.png)](/images/2021/03/image-12.png)

<figcaption>

The Win32App Migration Tool will connect to the specified site drive and setup the environment

</figcaption>

</figure>

Without specifying any other parameters, we are presented a Grid View, in a separate PowerShell window, with any apps that matched the **AppName** parameter that we passed. You can multi-select Applications using the Ctrl or Shift key. Press **OK** to pass the selected Application(s)

<figure>

[![](/images/2021/03/image-13.png)](/images/2021/03/image-13.png)

<figcaption>

Select an Application from the Grid View windows

</figcaption>

</figure>

The tool will gather the Application and Deployment Type information and export it to "%WorkingFolder%\\Details" _Applications.csv_ and _DeploymentTypes.csv_

[![](/images/2021/03/image-14.png)](/images/2021/03/image-14.png)

<figure>

[![](/images/2021/03/image-15-1024x459.png)](/images/2021/03/image-15.png)

<figcaption>

Snippet example of DeploymentTypes.csv export

</figcaption>

</figure>

##### Exporting Logos

Run the basic example command and add the _ExportLogo_ parameter

```
New-Win32App -AppName "Microsoft*" -ProviderMachineName bb-cm1.byteben.com -SiteCode BB1 -ExportLogo
```

[![](/images/2021/03/image-16.png)](/images/2021/03/image-16.png)

<figure>

[![](/images/2021/03/image-17.png)](/images/2021/03/image-17.png)

<figcaption>

Passing the ExportLogo parameter will export the Application logo to %WorkingFolder%\\Logos\\<_IconId>_\\logo.jpg

</figcaption>

</figure>

##### Reset the Log

Run the basic example command and add the _ResetLog_ parameter

```
New-Win32App -AppName "Microsoft*" -ProviderMachineName bb-cm1.byteben.com -SiteCode BB1 -ResetLog
```

<figure>

[![](/images/2021/03/image-18.png)](/images/2021/03/image-18.png)

<figcaption>

Passing the _ResetLog_ parameter will clear %WorkingFolder%\\Logs\\Main.log

</figcaption>

</figure>

##### Omit the Grid View

Run the basic example command and add the _NoOGV_ parameter to omit the Grid View. The script will accept the _AppName_ parameter and search for any Applications that match. You will not be prompted to choose from a list of available matches. Use **CAUTION** when using this parameter and at the same time using a wildcard in the _AppName_ parameter as an unexpected large number of Applications may be returned and processed by the tool

```
New-Win32App -AppName "Microsoft*" -ProviderMachineName bb-cm1.byteben.com -SiteCode BB1 -NoOGV
```

<figure>

[![](/images/2021/03/image-19.png)](/images/2021/03/image-19.png)

<figcaption>

Large numbers of results may be retuned if you use a wildcard in the AppName parameter and choose to omit the Grid View

</figcaption>

</figure>

##### Package Applications

Run the basic example command and add the _PackageApps_ parameter. The Win32 Content Prep Tool will be downloaded to %WorkingFolder%\\ContentPrepTool and the Deployment Type information gathered will be used to pass the required parameters to the Win32 Content Prep Tool. A resultant .intunewin file will be generated and exported to the %WorkingFolder%\\Win32Apps\\Application\_<GUID>\\DeploymentType\_<GUID>\\<Installer>.intunewin

```
New-Win32App -AppName "Microsoft*" -ProviderMachineName bb-cm1.byteben.com -SiteCode BB1 -PackageApps
```

<figure>

[![](/images/2021/03/image-20.png)](/images/2021/03/image-20.png)

<figcaption>

Folders will be created for the Application(s) and Deployment Type(s) found

</figcaption>

</figure>

<figure>

[![](/images/2021/03/image-21.png)](/images/2021/03/image-21.png)

<figcaption>

Content will be downloaded from the content source to %WorkingFolder%\\Content\\DeploymentType\_<GUID>

</figcaption>

</figure>

<figure>

[![](/images/2021/03/image-22.png)](/images/2021/03/image-22.png)

<figcaption>

The Win32 Content Prep Tool will create a .intunewin file for each Deployment Type in %WorkingFolder%\\Win32Apps\\Application\_<GUID>\\DeploymentType\_<GUID>\\<Installer>.intunewin

</figcaption>

</figure>

### Versioning

Versioning information and on-going development details can be found on the following GitHub page:-

[https://github.com/byteben/Win32App-Migration-Tool](https://github.com/byteben/Win32App-Migration-Tool)

<figure>

[![](/images/2021/03/image-24-1024x728.png)](/images/2021/03/image-24.png)

<figcaption>

Win32 App Migration Tool GitHub Repo

</figcaption>

</figure>

## Summary

At the time of writing this post the Win32App Migration Tool is still in BETA. I am thrilled by the community buzz and interest so far. I cannot wait to see the feedback during the Release and General Availability phases as the tool is developed in collaboration with the MEM community. I am particularly excited about the upcoming Console Extension in ConfigMgr!

If you have any feedback or ideas my DM's are open on Twitter [@byteben](https://twitter.com/byteben) or you can collaborate/report issues on the GitHub page [https://github.com/byteben/Win32App-Migration-Tool](https://github.com/byteben/Win32App-Migration-Tool)