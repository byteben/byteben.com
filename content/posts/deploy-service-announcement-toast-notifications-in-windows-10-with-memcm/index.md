---
title: "Deploy Service Announcement Toast Notifications in Windows 10 with MEMCM"
date: 2020-07-27
categories:
  - "ConfigMgr / MEMCM / SCCM"
  - "Microsoft"
  - "Scripts"
  - "Windows 10"
---

You may have seen that many apps these days use "Toast Notifications" to inform the user of an event or to ask them to do something. If you have moved your workload to Intune for Windows Update Policies you would have encountered them for sure. UWP and Desktop Apps can leverage the **ToastNotification** and **ToastNotificationManager** Class from the [Windows.UI.Notifications](https://docs.microsoft.com/en-us/uwp/api/windows.ui.notifications?view=winrt-19041) Namespace to create **ToastNotifier** objects to send a Toast Notification similar to below

<!--more-->

![](/images/2020/07/image-49.png)

### Background

If you are reading this post, you will have seen some Toast Notifications and thought "Cool, can I do that?" and that is where my journey started. Rewind a whole bunch of months and we were discussing how we cold reduce our software portfolio to make management easier and bring down our running costs at the same time. One piece of software in our portfolio was used to send notifications to our user base to inform them of issues that affected the whole company e.g. **Email Down / Phones Down / Coffee Machine Down**

And so the challenge began. Could I create my own Toast Notifications, on the fly, and deliver them using ConfigMgr - and the answer is yes!

### Feeling Toastie

Toast Notifications are flexible in their appearance and actionable states. Toasts can be delivered from a variety of predefined Toast Template types. They can range from simple text notifications to text with images.

Learn more about the different Toast Template Types at [https://docs.microsoft.com/en-us/uwp/api/windows.ui.notifications.toasttemplatetype?view=winrt-19041#fields](https://docs.microsoft.com/en-us/uwp/api/windows.ui.notifications.toasttemplatetype?view=winrt-19041#fields)

The Toast itself is built and styled from from an XML. In the XML we specify the various visual elements and actionable elements within our Toast. Do we want images, titles, text, buttons etc. Here is an example of what a basic, text only, Toast XML might look like using the Toast Template Type **ToastText02**

```
<toast>
    <visual>
        <binding template="ToastText02">
            <text id="1">My First Notification</text>
            <text id="2">I am so excited I sent you this</text>
        </binding>
    </visual>
</toast>
```

![](/images/2020/07/image-54.png)

or we can get funky and include a **Badge** **Image** using Toast Template Type **ToastImageAndText03** \*

```
<toast>
    <visual>
        <binding template="ToastImageAndText03">
            <text id="1">My First Notification</text>
            <text id="2">I am so excited I sent you this</text>
            <image id="1" src="C:\Scripts\badgeimage.jpg" />
        </binding>
    </visual>
</toast>
```

\* UPDATE: 25/10/20 - At this point I was asked to show the full code in order to display these simple toast templates. The full code is below but please continue reading the full article if you want an understanding of the code used

```
#Specify Launcher App ID
$LauncherID = "{1AC14E77-02E7-4E5D-B744-2EB1AE5198B7}\WindowsPowerShell\v1.0\powershell.exe"

#Load Assemblies
[Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime] | Out-Null
[Windows.Data.Xml.Dom.XmlDocument, Windows.Data.Xml.Dom.XmlDocument, ContentType = WindowsRuntime] | Out-Null

#Build XML Template
[xml]$ToastTemplate = @"
<toast>
    <visual>
        <binding template="ToastImageAndText03">
            <text id="1">My First Notification</text>
            <text id="2">I am so excited I sent you this Ben</text>
            <image id="1" src="C:\Scripts\badgeimage.jpg" />
        </binding>
    </visual>
</toast>
"@

#Prepare XML
$ToastXml = [Windows.Data.Xml.Dom.XmlDocument]::New()
$ToastXml.LoadXml($ToastTemplate.OuterXml)

#Prepare and Create Toast
$ToastMessage = [Windows.UI.Notifications.ToastNotification]::New($ToastXML)
[Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier($LauncherID).Show($ToastMessage)
```

![](/images/2020/07/image-53.png)

Why does the example above display the text **Windows PowerShell**? This is known as the **Attribution** property and is visible as we start to use more advanced Toast Template Types. The attribution property will be the name of the UWP or Desktop app that we use to call the Toast. For Windows Anniversary update and later, we can append to this value by modifying an element within our XML

```
<toast duration="$ToastDuration">
    <visual>
        <binding template="ToastImageAndText03">
            <text id="1">My First Notification</text>
            <text id="2">I am so excited I sent you this</text>
            <text placement="attribution">via your IT Team</text>
            <image id="1" src="C:\Scripts\badgeimage.jpg" />
        </binding>
    </visual>
</toast>
```

![](/images/2020/07/image-52.png)

So you can see we can add different properties into our XML to style the Toast the way we want it to look. In the PowerShell script this post, we are using another binding template called **ToastGeneric**. More information on how to style your Toasts can be found at [https://docs.microsoft.com/en-us/windows/uwp/design/shell/tiles-and-notifications/toast-ux-guidance](https://docs.microsoft.com/en-us/windows/uwp/design/shell/tiles-and-notifications/toast-ux-guidance)

### Images

Images are interesting. We can have [Badge Images](https://docs.microsoft.com/en-us/windows/uwp/design/shell/tiles-and-notifications/adaptive-interactive-toasts#app-logo-override) (also know as App Logo Override Images), [Hero Images](https://docs.microsoft.com/en-us/windows/uwp/design/shell/tiles-and-notifications/adaptive-interactive-toasts#hero-image) and [Inline Images](https://docs.microsoft.com/en-us/windows/uwp/design/shell/tiles-and-notifications/adaptive-interactive-toasts#inline-image). More information on all of these, including size and dimension restrictions can be found at [https://docs.microsoft.com/en-us/windows/uwp/design/shell/tiles-and-notifications/adaptive-interactive-toasts#image-size-restrictions](https://docs.microsoft.com/en-us/windows/uwp/design/shell/tiles-and-notifications/adaptive-interactive-toasts#image-size-restrictions)

![](/images/2020/07/image-62.png)

## In the Toaster

This post could very easily turn into a how to build a Toast tutorial so I will stop at this point. As I said at the beginning of the post, we had a very specific task we wanted our Toast to perform. The Toast, in our late example, will display a header image, known as a **Hero Image**, a **Badge Image**, some custom titles and text and two action buttons - one that opens the Service Portal Announcement page and the other that dismisses the Toast Notification. This will be used so the Service Desk can notify the user base of impending doom or "Systems Down". I believe this requirement and style of Toast could very easily apply to other organisations. We wanted to be able to send our users notifications for organisation events that affect either everyone or groups of people. So maybe this is a good point to introduce a Toast limitation.

**Toasts must be run in the USER context**

It would have been neat to be able to target devices but Toasts will only pop if ran in the users context. This means our delivery mechanism must target users. This immediately rules out the way I would have liked to have pushed Toasts out - and that was via the "Push Script" feature in ConfigMgr. Sure, given a few hours/days in the engine room we could muster this in the script to deploy as SYSTEM - happy to collaborate if anyone has any ideas.

As we saw earlier, we have to specify which UWP or Win32 Desktop application we are going to use to "Pop the Toast" - man I love that term. I wanted to be able to "Pop a Toast" to our users, giving them some initial information and then have them access the ICT Service Portal to find more information and updates. If you are using a Desktop App, that App **MUST** exist in the Apps Start-Up folder in Windows. You will need the **AppID** of the App you choose to "Pop Your Toast". In the following example, I chose **MSEdge.** I had originally tried two other very plausible Desktop Apps and these worked well too:-

- **Microsoft.SoftwareCenter.DesktopToasts**
- **{1AC14E77-02E7-4E5D-B744-2EB1AE5198B7}\\WindowsPowerShell\\v1.0\\powershell.exe**

Because I was launching a web page with an action button in my toast, using **MSEdge** as the app that handled my custom Toasts meant the browser would fire up in focus with the URL I specified in my Toast action argument.

You can find a list of available Apps and associated AppIDs by running the following command:-

```
Get-StartApps
```

![](/images/2020/07/image-55.png)

**Note:** Toasts can launch a browser when you specify **Protocol** on your action button as the activation type. If you want to run a custom action then you must register your own protocol to do this and that is outside of the scope of this blog post.

```
    <actions>
        <action arguments="https://byteben.com" content="Click Me" activationType="protocol" />
    </actions>
```

### Spreading Code on our Toast

Hopefully you understand some of the structure required to a "Pop a Toast" now. We have covered the XML requirements and how we want our Toast to look but we haven't discussed how we deliver it to our users. We are wrapping our XML styling in a PowerShell script. As with all scripts I write, anything that "could" change I like to pass as a parameter. It is safe to assume that if you want to send a notification to users, you may want to change the wording at each catastrophe. I don't really want the Service Desk guys and gals modifying scripts and updating content for the application. So we needed a way to read Toast text on the fly. In our example, we are doing this with another XML file. This file will be stored on a server accessible by everyone. The PowerShell script will read the XML elements in and set them as variables. Cool. We can have an XML that the service desk folks change each time or we could have multiple, pre fabricated XML's for various scenarios. We created XML's for the more common scenarios like "Email Down", "Phones Down", "Coffee Machine Down" etc.

Here is an example of what our XML will look like

```
<?xml version="1.0" encoding="UTF-8"?>
<ToastContent>
    <ToastTitle>We want to bring to your attention some important information. Please review the details below before contacting the Service Desk</ToastTitle>
    <Signature>Sent on behalf of the ICT Service Desk</Signature>
    <EventTitle>Major IT Issues - Flooding</EventTitle>
    <EventText>We are currently experiencing problems with all our systems. We are drinking coffee with our feet up and will provide an update shortly. Thank you for your patience</EventText>
    <ButtonTitle>Details</ButtonTitle>
    <ButtonAction>https://byteben.com</ButtonAction>
</ToastContent>
```

Lets look at each of these elements briefly:-

- **ToastTitle** - The Title of our Toast
- **Signature** - The text beside the attribution field (only visible in Anniversary update or higher)
- **EventTitle** - Title of the Event we are bringing to our users attention
- **EventText** - Details of the event and instructions to the user
- **ButtonTitle** - Our Single, actionable button Title
- **ButtonAction** - Web page / Service Desk Portal to load

And here is where the elements (in red) appear on the Toast Notification:-

![](/images/2020/07/image-63.png)

### Script

Source [https://github.com/byteben/Toast/blob/master/Toast\_Notify.ps1](https://github.com/byteben/Toast/blob/master/Toast_Notify.ps1)

We are doing some basic checks like does the XML exist, is it a valid, readable XML, get the current user name (Domain Joined clients Only) for a more custom experience and load the assemblies to run the Toast etc. I will keep the [ReadMe.md](https://github.com/byteben/Toast/blob/master/README.md) updated on GitHub.

### Update

**Version 2.0 - 07/02/2021**  
\-Basic logging added  
\-Toast temp directory fixed to $ENV:\\Temp\\$ToastGUID  
\-Removed unnecessary User SID discovery as its no longer needed when running the Scheduled Task as "USERS"  
\-Complete re-write for obtaining Toast Displayname. Name obtained first for Domain User, then AzureAD User from the IdentityStore Logon Cache and finally whoami.exe  
\- Added "AllowStartIfOnBatteries" parameter to Scheduled Task

**Version 1.2.105 - 05/002/2021**  
\-Changed how we grab the Toast Welcome Name for the Logged on user by leveraging whoami.exe - Thanks Erik Nilsson @dakire

**Version 1.2.28 - 28/01/2021**  
\-For AzureAD Joined computers we now try and grab a name to display in the Toast by getting the owner of the process Explorer.exe  
\-Better error handling when Get-xx fails

**Version 1.2.26 - 26/01/2021**  
\-Changed the Scheduled Task to run as -GroupId "S-1-5-32-545" (USERS).  
When Toast\_Notify.ps1 is deployed as SYSTEM, the scheduled task will be created to run in the context of the Group "Users".  
This means the Toast will pop for the logged on user even if the username was unobtainable (During testing AzureAD Joined Computers did not populate (Win32\_ComputerSystem).Username).  
The Toast will also be staged in the $ENV:Windir "Temp\\$($ToastGuid)" folder if the logged on user information could not be found.  
Thanks @CodyMathis123 for the inspiration via https://github.com/CodyMathis123/CM-Ramblings/blob/master/New-PostTeamsMachineWideInstallScheduledTask.ps1

**Version 1.2.14 - 14/01/21**  
\-Fixed logic to return logged on DisplayName - Thanks @MMelkersen  
\-Changed the way we retrieve the SID for the current user variable $LoggedOnUserSID  
\-Added Event Title, Description and Source Path to the Scheduled Task that is created to pop the User Toast  
\-Fixed an issue where Snooze was not being passed from the Scheduled Task  
\-Fixed an issue with XMLSource full path not being returned correctly from Scheduled Task

**Version 1.2.10 - 10/01/21**  
\-Removed XMLOtherSource Parameter  
\-Cleaned up XML formatting which removed unnecessary duplication when the Snooze parameter was passed. Action ChildNodes are now appended to ToastTemplate XML.

**Version 1.2 - 09/01/21**  
Added logic so if the script is deployed as SYSTEM it will create a scheduled task to run the script for the current logged on user

**Version 1.1 - 30/12/20**  
Added Snooze Switch option

```
<#
===========================================================================
Created on:   22/07/2020 11:04
Created by:   Ben Whitmore
Filename:     Toast_Notify.ps1
===========================================================================

Version 2.0 - 07/02/2021
-Basic logging added
-Toast temp directory fixed to $ENV:\Temp\$ToastGUID
-Removed unnecessary User SID discovery as its no longer needed when running the Scheduled Task as "USERS"
-Complete re-write for obtaining Toast Displayname. Name obtained first for Domain User, then AzureAD User from the IdentityStore Logon Cache and finally whoami.exe
- Added "AllowStartIfOnBatteries" parameter to Scheduled Task

Version 1.2.105 - 05/002/2021
-Changed how we grab the Toast Welcome Name for the Logged on user by leveraging whoami.exe - Thanks Erik Nilsson @dakire

Version 1.2.28 - 28/01/2021
-For AzureAD Joined computers we now try and grab a name to display in the Toast by getting the owner of the process Explorer.exe
-Better error handling when Get-xx fails

Version 1.2.26 - 26/01/2021
-Changed the Scheduled Task to run as -GroupId "S-1-5-32-545" (USERS). 
When Toast_Notify.ps1 is deployed as SYSTEM, the scheduled task will be created to run in the context of the Group "Users".
This means the Toast will pop for the logged on user even if the username was unobtainable (During testing AzureAD Joined Computers did not populate (Win32_ComputerSystem).Username).
The Toast will also be staged in the $ENV:Windir "Temp\$($ToastGuid)" folder if the logged on user information could not be found.
Thanks @CodyMathis123 for the inspiration via https://github.com/CodyMathis123/CM-Ramblings/blob/master/New-PostTeamsMachineWideInstallScheduledTask.ps1

Version 1.2.14 - 14/01/21
-Fixed logic to return logged on DisplayName - Thanks @MMelkersen
-Changed the way we retrieve the SID for the current user variable $LoggedOnUserSID
-Added Event Title, Description and Source Path to the Scheduled Task that is created to pop the User Toast
-Fixed an issue where Snooze was not being passed from the Scheduled Task
-Fixed an issue with XMLSource full path not being returned correctly from Scheduled Task

Version 1.2.10 - 10/01/21
-Removed XMLOtherSource Parameter
-Cleaned up XML formatting which removed unnecessary duplication when the Snooze parameter was passed. Action ChildNodes are now appended to ToastTemplate XML.

Version 1.2 - 09/01/21
-Added logic so if the script is deployed as SYSTEM it will create a scheduled task to run the script for the current logged on user.

-Special Thanks to: -
-Inspiration for creating a Scheduled Task for Toasts @PaulWetter https://wetterssource.com/ondemandtoast
-Inspiration for running Toasts in User Context @syst_and_deploy http://www.systanddeploy.com/2020/11/display-simple-toast-notification-for.html
-Inspiration for creating scheduled tasks for the logged on user @ccmexec via Community Hub in ConfigMgr https://github.com/Microsoft/configmgr-hub/commit/e4abdc0d3105afe026211805f13cf533c8de53c4

Version 1.1 - 30/12/20
-Added Snooze Switch option

Version 1.0 - 22/07/20
-Release

.SYNOPSIS
The purpose of the script is to create simple Toast Notifications in Windows 10

.DESCRIPTION
Toast_Notify.ps1 will read an XML file so Toast Notifications can be changed "on the fly" without having to repackage an application. The CustomMessage.xml file can be hosted on a fileshare.
To create a custom XML, copy CustomMessage.xml and edit the text you want to disaply in the toast notification. The following files should be present in the Script Directory

Toast_Notify.ps1
BadgeImage.jpg
HeroImage.jpg
CustomMessage.xml

.PARAMETER XMLSource
Specify the name of the XML file to read. The XML file must exist in the same directory as Toast_Notify.ps1. If no parameter is passed, it is assumed the XML file is called CustomMessage.xml.

.PARAMETER Snooze
Add a snooze option to the Toast

.EXAMPLE
Toast_Notify.ps1 -XMLSource "PhoneSystemProblems.xml"

.EXAMPLE
Toast_Notify.ps1 -Snooze
#>

Param
(
    [Parameter(Mandatory = $False)]
    [Switch]$Snooze,
    [String]$XMLSource = "CustomMessage.xml",
    [String]$ToastGUID
)

#Set Unique GUID for the Toast
If (!($ToastGUID)) {
    $ToastGUID = ([guid]::NewGuid()).ToString().ToUpper()
}

#Current Directory
$ScriptPath = $MyInvocation.MyCommand.Path
$CurrentDir = Split-Path $ScriptPath

#Set Toast Path to UserProfile Temp Directory
$ToastPath = (Join-Path $ENV:Windir "Temp\$($ToastGuid)")

#Test if XML exists
if (!(Test-Path (Join-Path $CurrentDir $XMLSource))) {
    throw "$XMLSource is invalid."
}

#Check XML is valid
$XMLToast = New-Object System.Xml.XmlDocument
try {
    $XMLToast.Load((Get-ChildItem -Path (Join-Path $CurrentDir $XMLSource)).FullName)
    $XMLValid = $True
}
catch [System.Xml.XmlException] {
    Write-Verbose "$XMLSource : $($_.toString())"
    $XMLValid = $False
}

#Continue if XML is valid
If ($XMLValid -eq $True) {

    #Create Toast Variables
    $ToastTitle = $XMLToast.ToastContent.ToastTitle
    $Signature = $XMLToast.ToastContent.Signature
    $EventTitle = $XMLToast.ToastContent.EventTitle
    $EventText = $XMLToast.ToastContent.EventText
    $ButtonTitle = $XMLToast.ToastContent.ButtonTitle
    $ButtonAction = $XMLToast.ToastContent.ButtonAction
    $SnoozeTitle = $XMLToast.ToastContent.SnoozeTitle

    #ToastDuration: Short = 7s, Long = 25s
    $ToastDuration = "long"

    #Images
    $BadgeImage = "file:///$CurrentDir/badgeimage.jpg"
    $HeroImage = "file:///$CurrentDir/heroimage.jpg"

    #Set COM App ID > To bring a URL on button press to focus use a browser for the appid e.g. MSEdge
    #$LauncherID = "Microsoft.SoftwareCenter.DesktopToasts"
    #$LauncherID = "{1AC14E77-02E7-4E5D-B744-2EB1AE5198B7}\WindowsPowerShell\v1.0\powershell.exe"
    $Launcherid = "MSEdge"

    #Dont Create a Scheduled Task if the script is running in the context of the logged on user, only if SYSTEM fired the script i.e. Deployment from Intune/ConfigMgr
    If (([System.Security.Principal.WindowsIdentity]::GetCurrent()).Name -eq "NT AUTHORITY\SYSTEM") {
        
        #Prepare to stage Toast Notification Content in %TEMP% Folder
        Try {

            #Create TEMP folder to stage Toast Notification Content in %TEMP% Folder
            New-Item $ToastPath -ItemType Directory -Force -ErrorAction Continue | Out-Null
            $ToastFiles = Get-ChildItem $CurrentDir -Recurse

            #Copy Toast Files to Toat TEMP folder
            ForEach ($ToastFile in $ToastFiles) {
                Copy-Item (Join-Path $CurrentDir $ToastFile) -Destination $ToastPath -ErrorAction Continue
            }
        }
        Catch {
            Write-Warning $_.Exception.Message
        }

        #Set new Toast script to run from TEMP path
        $New_ToastPath = Join-Path $ToastPath "Toast_Notify.ps1"

        #Created Scheduled Task to run as Logged on User
        $Task_TimeToRun = (Get-Date).AddSeconds(30).ToString('s')
        $Task_Expiry = (Get-Date).AddSeconds(120).ToString('s')
        If ($Snooze) {
            $Task_Action = New-ScheduledTaskAction -Execute "C:\WINDOWS\system32\WindowsPowerShell\v1.0\PowerShell.exe" -Argument "-NoProfile -WindowStyle Hidden -File ""$New_ToastPath"" -ToastGUID ""$ToastGUID"" -Snooze"
        }
        else {
            $Task_Action = New-ScheduledTaskAction -Execute "C:\WINDOWS\system32\WindowsPowerShell\v1.0\PowerShell.exe" -Argument "-NoProfile -WindowStyle Hidden -File ""$New_ToastPath"" -ToastGUID ""$ToastGUID"""
        }
        $Task_Trigger = New-ScheduledTaskTrigger -Once -At $Task_TimeToRun
        $Task_Trigger.EndBoundary = $Task_Expiry
        $Task_Principal = New-ScheduledTaskPrincipal -GroupId "S-1-5-32-545" -RunLevel Limited
        $Task_Settings = New-ScheduledTaskSettingsSet -Compatibility V1 -DeleteExpiredTaskAfter (New-TimeSpan -Seconds 600) -AllowStartIfOnBatteries
        $New_Task = New-ScheduledTask -Description "Toast_Notification_$($ToastGuid) Task for user notification. Title: $($EventTitle) :: Event:$($EventText) :: Source Path: $($ToastPath) " -Action $Task_Action -Principal $Task_Principal -Trigger $Task_Trigger -Settings $Task_Settings
        Register-ScheduledTask -TaskName "Toast_Notification_$($ToastGuid)" -InputObject $New_Task
    }

    #Run the toast of the script is running in the context of the Logged On User
    If (!(([System.Security.Principal.WindowsIdentity]::GetCurrent()).Name -eq "NT AUTHORITY\SYSTEM")) {

        $Log = (Join-Path $ENV:Windir "Temp\$($ToastGuid).log")
        Start-Transcript $Log

        #Get logged on user DisplayName
        #Try to get the DisplayName for Domain User
        $ErrorActionPreference = "Continue"

        Try {
            Write-Output "Trying Identity LogonUI Registry Key for Domain User info..."
            Get-Itemproperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Authentication\LogonUI" -Name "LastLoggedOnDisplayName" -ErrorAction Stop
            $User = Get-Itemproperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Authentication\LogonUI" -Name "LastLoggedOnDisplayName" | Select-Object -ExpandProperty LastLoggedOnDisplayName -ErrorAction Stop
        
            If ($Null -eq $User) {  
                $Firstname = $Null
            } 
            else {
                $DisplayName = $User.Split(" ")
                $Firstname = $DisplayName[0]
            }
        }
        Catch [System.Management.Automation.PSArgumentException] {
            "Registry Key Property missing" 
            Write-Warning "Registry Key for LastLoggedOnDisplayName could not be found."
            $Firstname = $Null
        }
        Catch [System.Management.Automation.ItemNotFoundException] {
            "Registry Key itself is missing" 
            Write-Warning "Registry value for LastLoggedOnDisplayName could not be found."
            $Firstname = $Null
        }

        #Try to get the DisplayName for Azure AD User
        If ($Null -eq $Firstname) {
            Write-Output "Trying Identity Store Cache for Azure AD User info..."
            Try {
                $UserSID = (whoami /user /fo csv | ConvertFrom-Csv).Sid
                $LogonCacheSID = (Get-ChildItem HKLM:\SOFTWARE\Microsoft\IdentityStore\LogonCache -Recurse -Depth 2 | Where-Object { $_.Name -match $UserSID }).Name
                If ($LogonCacheSID) { 
                    $LogonCacheSID = $LogonCacheSID.Replace("HKEY_LOCAL_MACHINE", "HKLM:") 
                    $User = Get-ItemProperty -Path $LogonCacheSID | Select-Object -ExpandProperty DisplayName -ErrorAction Stop
                    $DisplayName = $User.Split(" ")
                    $Firstname = $DisplayName[0]
                }
                else {
                    Write-Warning "Could not get DisplayName property from Identity Store Cache for Azure AD User"
                    $Firstname = $Null
                }
            }
            Catch [System.Management.Automation.PSArgumentException] {
                Write-Warning "Could not get DisplayName property from Identity Store Cache for Azure AD User"
                Write-Output "Resorting to whoami info for Toast DisplayName..."
                $Firstname = $Null
            }
            Catch [System.Management.Automation.ItemNotFoundException] {
                Write-Warning "Could not get SID from Identity Store Cache for Azure AD User"
                Write-Output "Resorting to whoami info for Toast DisplayName..."
                $Firstname = $Null
            }
            Catch {
                Write-Warning "Could not get SID from Identity Store Cache for Azure AD User"
                Write-Output "Resorting to whoami info for Toast DisplayName..."
                $Firstname = $Null  
            }
        }

        #Try to get the DisplayName from whoami
        If ($Null -eq $Firstname) {
            Try {
                Write-Output "Trying Identity whoami.exe for DisplayName info..."
                $User = whoami.exe
                $Firstname = (Get-Culture).textinfo.totitlecase($User.Split("\")[1])
                Write-Output "DisplayName retrieved from whoami.exe"
            }
            Catch {
                Write-Warning "Could not get DisplayName from whoami.exe"
            }
        }

        #If DisplayName could not be obtained, leave it blank
        If ($Null -eq $Firstname) {
            Write-Output "DisplayName could not be obtained, it will be blank in the Toast"
        }
                   
        #Get Hour of Day and set Custom Hello
        $Hour = (Get-Date).Hour
        If ($Hour -lt 12) { $CustomHello = "Good Morning $($Firstname)" }
        ElseIf ($Hour -gt 16) { $CustomHello = "Good Evening $($Firstname)" }
        Else { $CustomHello = "Good Afternoon $($Firstname)" }

        #Load Assemblies
        [Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime] | Out-Null
        [Windows.Data.Xml.Dom.XmlDocument, Windows.Data.Xml.Dom.XmlDocument, ContentType = WindowsRuntime] | Out-Null

        #Build XML ToastTemplate 
        [xml]$ToastTemplate = @"
<toast duration="$ToastDuration" scenario="reminder">
    <visual>
        <binding template="ToastGeneric">
            <text>$CustomHello</text>
            <text>$ToastTitle</text>
            <text placement="attribution">$Signature</text>
            <image placement="hero" src="$HeroImage"/>
            <image placement="appLogoOverride" hint-crop="circle" src="$BadgeImage"/>
            <group>
                <subgroup>
                    <text hint-style="title" hint-wrap="true" >$EventTitle</text>
                </subgroup>
            </group>
            <group>
                <subgroup>
                    <text hint-style="body" hint-wrap="true" >$EventText</text>
                </subgroup>
            </group>
        </binding>
    </visual>
    <audio src="ms-winsoundevent:notification.default"/>
</toast>
"@

        #Build XML ActionTemplateSnooze (Used when $Snooze is passed as a parameter)
        [xml]$ActionTemplateSnooze = @"
<toast>
    <actions>
        <input id="SnoozeTimer" type="selection" title="Select a Snooze Interval" defaultInput="1">
            <selection id="1" content="1 Minute"/>
            <selection id="30" content="30 Minutes"/>
            <selection id="60" content="1 Hour"/>
            <selection id="120" content="2 Hours"/>
            <selection id="240" content="4 Hours"/>
        </input>
        <action activationType="system" arguments="snooze" hint-inputId="SnoozeTimer" content="$SnoozeTitle" id="test-snooze"/>
        <action arguments="$ButtonAction" content="$ButtonTitle" activationType="protocol" />
        <action arguments="dismiss" content="Dismiss" activationType="system"/>
    </actions>
</toast>
"@

        #Build XML ActionTemplate (Used when $Snooze is not passed as a parameter)
        [xml]$ActionTemplate = @"
<toast>
    <actions>
        <action arguments="$ButtonAction" content="$ButtonTitle" activationType="protocol" />
        <action arguments="dismiss" content="Dismiss" activationType="system"/>
    </actions>
</toast>
"@

        #If the Snooze parameter was passed, add additional XML elements to Toast
        If ($Snooze) {

            #Define default and snooze actions to be added $ToastTemplate
            $Action_Node = $ActionTemplateSnooze.toast.actions
        }
        else {

            #Define default actions to be added $ToastTemplate
            $Action_Node = $ActionTemplate.toast.actions
        }

        #Append actions to $ToastTemplate
        [void]$ToastTemplate.toast.AppendChild($ToastTemplate.ImportNode($Action_Node, $true))
        
        #Prepare XML
        $ToastXml = [Windows.Data.Xml.Dom.XmlDocument]::New()
        $ToastXml.LoadXml($ToastTemplate.OuterXml)
    
        #Prepare and Create Toast
        $ToastMessage = [Windows.UI.Notifications.ToastNotification]::New($ToastXML)
        [Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier($LauncherID).Show($ToastMessage)

        Stop-Transcript
    }
}
```

### Building the Package

The very nature of a Toast Notification is to "Set and Forget" it. In our script, we are setting the Toast duration to **Long** which means it will stay open for 25 seconds. Once the Toast disappears it remains in the Notification Center for 3 days. At the moment, I couldn't think of a suitable way to set a detection method for this script because there is no payload. The best option I have found for now is to deliver the Toasts using **packages** - arghhh..run for the hills and chase him with a pitch fork. Please contribute if you can think of a better way to do this.

To create the package in MEMCM, you will need the following files in your Package Content Source Directory

- **Toast\_Notify.ps1**
- **BadgeImage.jpg**
- **HeroImage.jpg** (364 x 180px, 3MB Normal Connection / 1MB Metered Connection)
- **CustomMessage.xml**

Absolutely use your own Hero and Badge Image. The dimensions and size for the Hero Image are quite strict. All of these files are available in my Git repository so go grab them for your test labs. You will also find some other Custom Message XML's too to play with [https://github.com/byteben/Toast](https://github.com/byteben/Toast)

1\. From the ConfigMgr Console, navigate to **Software Library > Packages** **\> Create Package**

2\. Enter a **Name** e.g. **"Toast Notifications**"

3\. Select **This package contains source files** and browse to the content source directory that contains the files listed above

4\. Click **Next**

5\. Ensure **Standard Program** is selected on the Create Program Type page and click **Next**

6\. Enter the following Information:-

**Name:** Custom Toast Notification  
**Command Line:** PowerShell.exe -File "Toast\_Notify.ps1" -XMLOtherSource "\\\\MyFileServer\\Toast Notifications Custom Message\\CustomMessage.xml"  
**Run:** Hidden  
**Program Can Run:** Only when a user is logged on  
**Run Mode:** Run with user's rights

![](/images/2020/07/image-59.png)

7\. Click **Next**

8\. Select **This program can run only on specified platforms** and select **All Windows 10(64-bit)**

9\. Set **Estimated disk space** to **52kb**

10\. Set **Maximum allowed run time (minutes)** to 15

11\. Click **Next** and then Click **Close**

You can create multiple programs for the same package if you want to use the predefined XML's on my Git. Just change the Name and Command Line to identify the correct XMLs to pass to the script.

### Deploy to Users

Now all that left to do is deploy our Toast package to our test user group. Remember, we must deploy to a **User Collection**

1\. Right click the newly created Program **Custom Toast Notification** and choose **Deploy**

2\. Click **Browse** and choose the **User Collection** you wish to deploy the Toast Notification to

3\. Click **Next**

4\. If you haven't already done so, choose which Distribution Point or Distribution Point Group to add the package to and Click **Next**

5\. Ensure the **Purpose** is set to **Required**

6\. Click **New** in the **Assignment Schedule** pane and Select **Assign Immediately after this event > As soon as possible** (or a schedule of your choice)

7\. in the **Rerun behaviour** drop down, Select **Always rerun program**

8\. Click **Next** four times and then Click **Close**

At the next User Policy Refresh Interval, your clients should receive the Toast. You can always force a User Policy Notification refresh from your device node in the ConfigMgr console

You can monitor the script deployment in the **Ccm32BitLauncher.log** file

### Summary

That was a whistle stop tour of deploying Toast Notifications with MEMCM. I wanted to give you an introduction into how Toast Notifications are formed and how I deploy them using MEMCM. Most of the complex work is in the script which I hope to develop. If you want to contribute on GitHub, I would be more than happy to work with you on Pull requests and suggestions.  
  
I spent a good chunk of my spare time making it my goal to understand how Toast Notifications work in Windows. This is the end result - a labour of love.  
  
I wouldn't be doing the community justice if I didn't mention Martins work on Toast Notifications too. He has really developed a neat solution. Go and check it out [https://www.imab.dk/windows-10-toast-notification-script/](https://www.imab.dk/windows-10-toast-notification-script/)  
  
[Gary Block](http://@gwblok) also has a really neat example in his GitHub repository too and uses Base64 to encode his images - so cool! [https://github.com/gwblok/garytown/blob/master/Office365/CI\_ToastLaunch\_Remediate.ps1](https://github.com/gwblok/garytown/blob/master/Office365/CI_ToastLaunch_Remediate.ps1)  
  
Thanks too to [Chris Roberts](https://twitter.com/young_robbo) and [Guy Leech](https://twitter.com/guyrleech) for helping with some background work and coding conundrums, I valued your input.