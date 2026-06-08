---
title: "Deploy custom Microsoft Teams backgrounds, easily, with PowerShell and Intune"
date: 2020-06-28
categories:
  - "ConfigMgr / MEMCM / SCCM"
  - "Intune"
  - "Microsoft"
  - "Office 365"
  - "Scripts"
  - "Windows 10"
---

This one has been in my blog queue for a while. @stuffygibbon did a shout out on Twitter so I thought I'd bring this post forward and show you how you can deploy a PowerShell script from Intune to install a custom background for your Microsoft Teams users!

<!--more-->

### Custom Backgrounds for Teams?

Microsoft announced a new background feature within Microsoft Teams. Towards the end of March/beginning of April 2020 we were able to use custom backgrounds in our Microsoft Teams meetings - whaaaa I hear you cry!

![](/images/2020/04/image-40.png)

What some eagle eyed cherries started to realise is that you could add your own backgrounds to Teams by placing your background/s in the following folder

> %AppData%\\Microsoft\\Teams\\Backgrounds\\Uploads

### The Next Level

That is a cool feature right there - but as Admins we always ask "How do I automate this for my users?

There are many ways to cook this beast, @stuffygibbon was using Intune so I pondered. Shall I just create a batch file and package it with an image using IntuneWinAppUtil to copy the image file to the users %AppData% folder? Sure - perfectly reasonable. But I want to show you another way - a way which means you DON'T have to repackage scripts and images each time you want to send out a new background to your Teams users.

I will show you how we can retrieve background images from a URL and put them in the users profile to be used as a custom background in a Teams meeting.

Q: "Ben - So you can package only PowerShell scripts using the Win32 Content Prep tool without a payload?" - **YES!** "And the Script (disguised as an app) will appear in the Company Portal?" - **YES!** "And you can pass parameters to the installation command line meaning you won't need to modify and re-package the script each time you copy it to create a new app in Intune?" **YES!**

Let's cook.

### PowerShell

I wanted the solution to use a single script for both Install and Uninstall. I also didn't want to have to re-write and re-package the script should I need to use it again. I should be able to create a new App in Intune and reuse the same Win32App again. In order to achieve this, I would need to specify the image name and URL as a parameter in the installation command line.

I also love the flexibility of using a Win32App to deploy my script. The script attempts to download a file using the Invoke-WebRequest method and I liked the idea that I could get the Intune Management Extension to retry deployment if it failed. I will set an exit code in the script on download failure and tell Intune to retry the script again if it see's that exit code (Intune will attempt 3 retires every 5mins if you specify an exit code to force a retry)

I will need to pass 3 parameters to my script.

1. Install or Uninstall
2. Filename
3. URL where the file is hosted \*

\* You may not want your corporate Teams Background to sit on a Public URL so consider using Azure Active Directory Application Proxy to host the image. You can find more about that here [https://byteben.com/bb/azure-ad-application-proxy-accessing-your-internal-web-apps-from-the-internet/](https://byteben.com/bb/azure-ad-application-proxy-accessing-your-internal-web-apps-from-the-internet/)

So the script is fairly simple. I will deploy it as a Win32 App in the user context so I can target the %AppData% Environment Variable. Intune also supports the use of the %AppData% variable when deploying an app in the User context - this makes our Detection Rule quite straight forward too. If the download fails I will set an Exit Code of 1. I will tell the App to "Retry" if it sees an Exit code of 1. Exit code 0 indicates a successful deployment.

#### Update

**Version 1.3 - 11/01/21**  
\-Fixed an issue with the script not downloading content in some scenarios in PoSh 5 by using the "UseBasicParsing" option for invoke-webrequest and changing how the Full URL is created. Thanks/Credit to @DirkHaex  
\-Changed URI formatting

```
<#	
===========================================================================
Created on:   	28/04/2020 22:08
Created by:   	Ben Whitmore
Organization: 	byteben.com
Filename:     	Custom_Teams_Background.ps1
===========================================================================

1.3 - 11/01/21
-Fixed an issue with the script not downloading content in some scenarios in PoSh 5 by using the "UseBasicParsing" option for invoke-webrequest and changing how the Full URL is created. Thanks/Credit to @DirkHaex
-Changed URI formatting

1.202804.02 - 28/04/20
-Added check that switch Install/Uninstall was used

1.202804.01 - 28/04/20
-Initial Release

.DESCRIPTION
Script to download an image file from a URL and place in a users Microsoft Teams Backgrounds\Uploads folder

.EXAMPLE
Custom_Teams_Background.ps1 -Install -BackgroundName "Teams_Back_1.jpg" -BackgroundUrl "https://byteben.com/bb/Downloads/Teams_Backgrounds/"

.EXAMPLE
Custom_Teams_Background.ps1 -Uninstall -BackgroundName "Teams_Back_1.jpg"

.PARAMETER Install
Switch parameter which must be used with the parameters BackgroundName and BackgroundURL but not Uninstall

.PARAMETER UnInstall
Switch parameter which must be used with the parameter BackgroundName but not BackgroundURL or Install

.PARAMETER BackgroundName
Specify the image file name located at your URL e.g. "Teams_Back_1.jpg"

.PARAMETER BackgroundUrl
Specify the BackgroundURL where your image file is located. URL should end with a forward slash. e.g. "https://byteben.com/bb/Downloads/Teams_Backgrounds/"

#>

#Get background file name and URL from Intune app installation parameter
#NOTE: We specify these individually so we can remove the background image using the same script
Param (
    [Parameter(Mandatory = $True)]
    [string]$BackgroundName,
    [Parameter(Mandatory = $False)]
    [uri]$BackgroundUrl,
    [Switch]$Install,
    [Switch]$UnInstall
)

#Check if the Install or Uninstall parameter was passed to the script
if (1 -ne $Install.IsPresent + $Uninstall.IsPresent) {
	Write-Warning "Please specify one of either the -Install or -Uninstall parameter when running this script"
	exit 1
}

#Specify Teams custom background directory
$TeamsDir = Join-Path $ENV:Appdata "Microsoft\Teams\Backgrounds\Uploads"
$BackgroundDestination = Join-Path $TeamsDir $BackgroundName

If ($Install) {

    #Create Backgrounds\Uploads folder if it doesn't exist
    If (!(Test-Path $TeamsDir)) {
        New-Item -ItemType Directory -Path $TeamsDir -Force | Out-Null
    }

    #Create Full URL for background image
    $FullUrl = [Uri]::new([Uri]::new($BackgroundUrl), $BackgroundName).ToString()
    New-Object uri $FullUrl
    

    #Test if URL is valid
    Try {
        #Attempt URL get and set Status Code variable
        $URLRequest = Invoke-WebRequest -UseBasicParsing -URI $FullURL -ErrorAction SilentlyContinue
        $StatusCode = $URLRequest.StatusCode
    }
    Catch {
        #Catch Status Code on error
        $StatusCode = $_.Exception.Response.StatusCode.value__
        Exit 1
    }

    #If URL exists
    If ($StatusCode -eq 200) {

        #Attempt File download
        Try {
            Invoke-WebRequest -UseBasicParsing -Uri $FullUrl -OutFile $BackgroundDestination -ErrorAction SilentlyContinue

            #If download was successful, test the file was saved to the correct directory
            If (Test-Path $BackgroundDestination) {
                Write-Output "File download Successfull. File saved to $BackgroundDestination"
                Exit 0
            }
            else {
                Write-Warning "The download was interrupted or an error occured moving the file to the destination you specified"
                Exit 1
            }
        }
        Catch {
            #Catch any errors during the file download
            write-Warning "Error downloading file: $FullUrl" 
            Exit 1
        }
    }
    else {
        #For anything other than status 200 (URL OK), throw a warning
        Write-Warning "URL Does not exists or the website is down. Status Code: $StatusCode" 
        Exit 1
    }
}
If ($Uninstall) {

    #Test the file is in directory
    If (Test-Path $BackgroundDestination) {
		
        #Remove file from directory
        Remove-Item $BackgroundDestination -Force -Recurse -ErrorAction Stop 
        Exit 0
    }
    else {
        #Write warning if file does not exist
        Write-Warning "The File $BackgroundName does not exist in location $TeamsDir"
        Exit 1
    }
}
```

Source: [https://github.com/byteben/MSTeams/blob/b8db126f4dd6af91f14dd6b1a2fa2b0447e67b9b/Custom\_Teams\_Background.ps1](https://github.com/byteben/MSTeams/blob/b8db126f4dd6af91f14dd6b1a2fa2b0447e67b9b/Custom_Teams_Background.ps1)

### Putting it all together

#### Create the .Intunewin File

1 . Download the Win32 Content Prep Tool Zip file in order to create the .intunewin file for deployment [https://github.com/microsoft/Microsoft-Win32-Content-Prep-Tool/archive/master.zip](https://github.com/microsoft/Microsoft-Win32-Content-Prep-Tool/archive/master.zip)

2 . Extract the tool to a local folder, e.g. **C:\\Microsoft-Win32-Content-Prep-Tool-master**

You should see the following files

![](/images/2020/04/image-42.png)

3 . Make sure you "Unblock" IntuneWinAppUtil.exe

![](/images/2020/04/image-43.png)

4 . Download the PowerShell Script and save it into the same directory. Do not rename it. Script here :- [**Custom\_Teams\_Background.ps1**](https://github.com/byteben/MSTeams/blob/master/Custom_Teams_Background.ps1)

Your directory should now look like this

![](/images/2020/04/image-44.png)

5 . Double click IntuneWinAppUtil.exe

Specify the following Values:-

Source Folder: **C:\\Microsoft-Win32-Content-Prep-Tool-master**  
Setup File: **Custom\_Teams\_Background.ps1**  
Output Folder: **.\\**  
Specify Catalog Folder?: **N**

![](/images/2020/04/image-45.png)

Your directory should now look like this

![](/images/2020/04/image-61.png)

#### Create the Win32 App in Intune

1 . Navigate to the Microsoft Endpoint Manager admin Centre [https://devicemanagement.microsoft.com](https://devicemanagement.microsoft.com) and Select **Apps > All apps > + Add**

![](/images/2020/04/image-41.png)

2 . Choose **Other > Windows app (Win32**)

3 . Click **Select**

4 . Choose **Select app package file**

![](/images/2020/04/image-47.png)

5 . Browse to the **Custom\_Teams\_Background.intunewin** file we created previously and Select **OK**

![](/images/2020/04/image-48.png)

6 . Fill in the application information, the items highlighted in the orange boxes are required - other boxes are optional.

![](/images/2020/04/image-49.png)

7 . Click **Next**

8\. Enter the following information

![](/images/2020/07/image-28.png)

Install Command:  
**Powershell.exe -windowstyle hidden -file "Custom\_Teams\_Background.ps1" -Install -BackgroundName "Teams\_Back\_1.jpg" -BackgroundUrl "https://byteben.com/bb/Downloads/Teams\_Backgrounds/"**  
Uninstall Command:  
**Powershell.exe -windowstyle hidden -file "Custom\_Teams\_Background.ps1" -Uninstall -BackgroundName "Teams\_Back\_1.jpg"**  
Install behaviour: **User**  
Device restart behaviour: **No specific action**  
Return code: **1**, Code type: **Retry**

9 . Click **Next**

10 . Fill in the app requirements. The settings highlighted require you to enter a value that is suitable for your environment.

![](/images/2020/04/image-51.png)

11 . Click **Next**

12 . Under **Detection rules**, Select **Manaully configure detection riles** from the **Rules format** drop down box

13 . Click **+Add**

14 . Enter the following settings:-

![](/images/2020/04/image-52.png)

Rule Type: **File**  
Path: **%AppData%\\Microsoft\\Teams\\Backgrounds\\Uploads**  
File or Folder: **Teams\_Back\_1.jpg** (or the name of your image file)  
Detection Method: **File or folder exists**

15 . Click **OK**

16 . Click **Next**

17 . Review Dependencies and Click **Next** (we don't have any specific dependencies for this app)

18 . Assign the App to you **Users / User Group** \*

19 . Click **Next**

20 . Review your Settings and Click **Create**

![](/images/2020/07/image-29.png)

**\* Don't forget to make this deployment "Available" for enrolled devices to ensure it gets installed in the user context. If you deploy it as "Required" the app will attempt to install in the SYSTEM context and follow the ENV:Appdata variable for the SYSTEM profile.**

### Testing it Out

Log on to a Windows device with an account that you deployed the application to and open the Company Portal to view your recently created app. At the same time, open file explorer to **%AppData%\\Microsoft\\Teams\\Backgrounds\\Uploads** so you can see the magic happen.

Click **Install**

![](/images/2020/04/image-57.png)

The PowerShell window will flash and disappear (we specified the **\-windowstyle hidden** parameter earlier). Check file explorer to view the downloaded custom background - exciting!

![](/images/2020/04/image-58-1024x495.png)

Verify you can use the downloaded file as a custom background in Microsoft Teams

![](/images/2020/04/image-59.png)

Review the Intune Management Extension Logs at C:\\ProgramData\\Microsoft\\IntuneManagementExtension

![](/images/2020/04/image-60-1024x467.png)

### Summary

In this post, we deployed a PowerShell script as a Win32 app to get a background image from a URL and set it as an available background to use in a Microsoft Teams meeting.

To me this seemed a simple way to create apps in Intune to perform different tasks by simply altering some installation parameters and detection logic without having to edit scripts and repackage them with the Win32 Content Prep tool

Thanks for reading. Ben