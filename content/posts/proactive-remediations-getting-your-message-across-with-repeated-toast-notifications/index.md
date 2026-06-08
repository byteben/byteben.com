---
title: "Proactive Remediations - Getting your message across with repeated Toast Notifications"
date: 2021-06-08
tags: ["endpointanalytics", "intune", "powershell", "proactive-remediations", "toast-notification"]
categories: ["intune", "microsoft", "rssexclude", "scripts", "windows-10"]
---

<figure>

<!--more-->

![](/images/2021/05/image-75.png)

<figcaption>

Getting your message across

</figcaption>

</figure>

> Sometimes you just need to get your message across

We have seen many great community solutions built around the Toast Notification framework. Notifying users of impending actions and faults is key to keeping them engaged and interested in the health and longevity of their devices. [Maurice Daley](https://msendpointmgr.com/author/mauriced/) has written some great blog posts on Proactive Remediations lately and his solutions often display a Toast Notification to users to let them know "what is going on" - check out his recent post on [Proactive Hard Drive Replacement with Endpoint Analytics](https://msendpointmgr.com/2021/04/21/proactive-hard-drive-replacement-with-endpoint-analytics/)

### I'll Toast to that

A while back I put together a Toast Notification solution that would allow you to notify users of "impending" actions that would affect them. Toast Notify is available on my GitHub, grab it before it gathers more dust [byteben/Toast (github.com)](https://github.com/byteben/Toast)

Just recently we had a customer who wanted to notify their users of a Feature update that was being rolled out that afternoon. In spite of best efforts, well coordinated communications and weeks of planning they knew that some people would "forget the memo" and switch their devices off as they left for the day.

We knew that Toast Notifications would be ideal for that "Just in Time" reminder. But why stop at just one notification? What if the user just dismissed the notification without paying too much attention - all that effort of popping a Toast Notification and it just got ignored.

### Spreading on some Jam

So this idea of popping more than one Toast was intriguing. I adapted the Toast script a while ago to accommodate it being delivered/run in the SYSTEM context - we know that Toast Notifications must be popped in the USER context. I took the idea from [Cody Mathis](https://twitter.com/CodyMathis123) over at Patch My PC (Thanks Cody) to run the Scheduled Task as the "USERS" account when the script was delivered in the SYSTEM context. It works pretty well.

The Scheduled Task had a single trigger which would re-run the script in the context of the logged on user

<figure>

![](/images/2021/05/image-77.png)

<figcaption>

Scheduled Task will run for the logged on user

</figcaption>

</figure>

### Getting Trigger Happy

Going back to our original scenario, we want to pop the same Toast multiple times to "Get the message across". Obviously you need to make sure this would be practical - the sales exec might not appreciate multiple Toasts popping during a PowerPoint sales pitch. But this blog is all about shouting your message from the roof tops - so lets continue. In our script we can define multiple triggers in a scheduled task to ensure out Toast pops multiple times. We accommodate this by allowing the script admin to enter an array of times when they want the trigger to fire

<figure>

![](/images/2021/05/image-78.png)

<figcaption>

Array of times for the Scheduled Task Triggers

</figcaption>

</figure>

<figure>

![](/images/2021/05/image-79.png)

<figcaption>

Triggers all set to pop the Toast Notification

</figcaption>

</figure>

We simply pulled the $ToastTimes array members into our Scheduled Task creation script - pretty neat

![](/images/2021/05/image-80.png)

### Proactive Remediations

So how do we deliver this script? [Proactive Remediations](https://msendpointmgr.com/2020/06/25/endpoint-analytics-proactive-remediations/) of course! There was a challenge here. We had the day and times that these Toast notifications needed to pop from the customer. How could we ensure the Proactive Remediation would remediate (deliver the script) on time? We didn't want users to get the Toast the following day AFTER the Feature Update was delivered to them.

This is where you can get a little creative with your scripts. In order to remediate the device (create a scheduled task to pop our Toast), the detection script must exit with an Exit Code of "1" - the device is "Not Complaint". If the detection script exits with an Exit Code of "0" the device is marked as "Compliant" and the remediation script will not run.

In our detection script, we do two things. If the client date does not match the date we intend the toasts to pop - we exit the script with an Exit Code of "0" (Do not remediate). If the script has run before (flagged by a registry value that gets added when the remediation script runs) we also exit the script with an Exit Code of "0". If the client date matches the date in the detection script and the remediation script has not run before - we exit with an Exit Code of "1" - which means remediate.

<figure>

![](/images/2021/05/image-81.png)

<figcaption>

Remediate if the client date matches and remediation hasn't occurred previously

</figcaption>

</figure>

### Putting the pieces together

"Script Changes are Required"

**Toast\_WU\_Detection.ps1**

You need to adjust the **$Targetdate** variable in line 5. The date should reflect when you want the scheduled task to run on the users device. Planning is key. Make sure you assign the Proactive Remediation giving enough time for your device to check in and run the remediation script "before" the scheduled task is triggered to run.

_$TargetDate = (Get-Date -Day 24 -Month 5 -Year 2021).ToString("ddMMyyy")_

**Toast\_WU\_Notification.ps1**

You will need to adjust the **$ToastTimes** array on line 24. The array members should be the times you want multiple triggers creating in the scheduled task

_$ToastTimes = @("15:00", "16:00", "17:00")_

**Toast\_WU\_Detection.ps1**  
[https://github.com/byteben/Windows-10/blob/master/Toast\_WU\_Notification/Toast\_WU\_Detection.ps1](https://github.com/byteben/Windows-10/blob/master/Toast_WU_Notification/Toast_WU_Detection.ps1)

```
$Path = "HKLM:\Software\!ProactiveRemediations"
$Name = "20H2NotificationSchTaskCreated"
$Value = 1

$TargetDate = (Get-Date -Day 24 -Month 5 -Year 2021).ToString("ddMMyyy")
$ClientDate = (Get-Date).ToString("ddMMyyy")

If (!($TargetDate -eq $ClientDate)){
    Write-Output "Remediation Target Date""$($TargetDate)"" not valid. Client date is $ClientDate. Remediation will not run."
    Exit 0
}

Try {
    $Registry = Get-ItemProperty -Path $Path -Name $Name | Select-Object -ExpandProperty $Name
    If ($Registry -eq $Value){
        Write-Output "Remediation not required."
        Exit 0
    } 
    Write-Output "Remediation required"
    Exit 1
} 
Catch {
    Write-Warning "Error Caught. Remediation will not run."
    Exit 0
}
```

**Toast\_WU\_Notification.ps1**  
[https://github.com/byteben/Windows-10/blob/master/Toast\_WU\_Notification/Toast\_WU\_Notification.ps1](https://github.com/byteben/Windows-10/blob/master/Toast_WU_Notification/Toast_WU_Notification.ps1)

```
<#
	.NOTES
	===========================================================================
	 Created on:   	17/05/2021 11:12 AM
	 Created by:   	Maurice Daly / Ben Whitmore
	 Organization: 	CloudWay
	 Filename:     	Toast_WU_Notification.ps1
	===========================================================================
	.DESCRIPTION
		Notify the logged on user of a pending Windows Updates Installation

        Adding multiple times to the $ToastTimes array will pop the toast at regular intervals
#>

Param
(
    [Parameter(Mandatory = $False)]
    [String]$ToastGUID
)

#region ToastCustomisation

#Create Toast variables, 24HR Time Format
$ToastTimes = @("15:00", "16:00", "17:00")

#Toast Message
$ToastTitle = "an Important Update is Scheduled"
$ToastText = "You MUST leave your computer on after 17:00 today. Failure to do so will result in a delay accessing your computer tomorrow"

#Toast Images
[uri]$ImageRepositoryUri = "https://raw.githubusercontent.com/byteben/Toast/master/"
$BadgeImgName = "badgeimage.jpg"
$HeroImgName = "heroimage.jpg"

#ToastScenario: Alarm, Reminder
$ToastScenario = "reminder"

#ToastDuration: Short = 7s, Long = 25s
$ToastDuration = "long"

#endregion ToastCustomisation

#region ToastRunningValues

#Set Unique GUID for the Toast
If (!($ToastGUID)) {
    $ToastGUID = ([guid]::NewGuid()).ToString().ToUpper()
}

#Format Time
$TaskTimes = @()
Foreach ($ToastTime in $ToastTimes) {
    $ToastTimeToUse = ([datetime]::ParseExact($ToastTime, "HH:mm", $null))
    $TaskTimes += $ToastTimeToUse
}

#Current Directory
$ScriptPath = $MyInvocation.MyCommand.Path
$CurrentDir = Split-Path $ScriptPath

#Set Toast Path to Temp Directory
$ToastPath = (Join-Path $ENV:Windir -ChildPath "temp\$($ToastGUID)")

#Set Toast PS File Name
$ToastPSFile = $MyInvocation.MyCommand.Name

#Create image destination variables
$BadgeImage = Join-Path -Path $ENV:Windir -ChildPath "temp\$BadgeImgName"
$HeroImage = Join-Path -Path $ENV:Windir -ChildPath "temp\$HeroImgName"

#endregion ToastRunningValues

#region ScriptFunctions

# Toast function
function Display-ToastNotification {

    #Check for Constrained Language Mode
    $PSExecutionContext = $ExecutionContext.SessionState.LanguageMode

    If ($PSExecutionContext -eq "ConstrainedLanguage") {   
        Write-Warning "Execution Context is set to ConstrainedLanguage. Toast will not run. Ensure your AppLocker policy allow scripts to run from ""$($ToastPath)"" - or even better, sign the script and trust the publisher."
        Exit 1
    }

    #Force TLS1.2 Connection
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

    #Fetching images from URI
    $BadgeImageUri = [Uri]::new([Uri]::new($ImageRepositoryUri), $BadgeImgName).ToString()
    $HeroImageUri = [Uri]::new([Uri]::new($ImageRepositoryUri), $HeroImgName).ToString()
    New-Object uri $BadgeImageUri
    New-Object uri $HeroImageUri

    Invoke-WebRequest -UseBasicParsing -Uri $BadgeImageUri -OutFile $BadgeImage -ErrorAction SilentlyContinue
    Invoke-WebRequest -UseBasicParsing -Uri $HeroImageUri -OutFile $HeroImage -ErrorAction SilentlyContinue
	
    #Set COM App ID > To bring a URL on button press to focus use a browser for the appid e.g. MSEdge
    #$LauncherID = "Microsoft.SoftwareCenter.DesktopToasts"
    $LauncherID = "{1AC14E77-02E7-4E5D-B744-2EB1AE5198B7}\WindowsPowerShell\v1.0\powershell.exe"
    #$Launcherid = "MSEdge"
	
    #Dont Create a Scheduled Task if the script is running in the context of the logged on user, only if SYSTEM fired the script i.e. Deployment from Intune/ConfigMgr
    If (([System.Security.Principal.WindowsIdentity]::GetCurrent()).Name -eq "NT AUTHORITY\SYSTEM") {
		     
        #Prepare to stage Toast Notification Content in Toast Folder
        Try {
			
            #Create TEMP folder to stage Toast Notification Content in %TEMP% Folder
            New-Item $ToastPath -ItemType Directory -Force -ErrorAction Continue | Out-Null
            $ToastFiles = Get-ChildItem $CurrentDir -Filter *.ps1 -Recurse

            #Copy Toast Files to Toat TEMP folder
            ForEach ($ToastFile in $ToastFiles) {
                Copy-Item -Path (Join-Path -Path $CurrentDir -ChildPath $ToastFile) -Destination $ToastPath -ErrorAction Continue
            }
        }
        Catch {
            Write-Warning $_.Exception.Message
        }
		
        #Created Scheduled Tasks to run as Logged on User

        #New ToastFile to run for Scheduled Task

        $NewToastFile = Join-Path -Path $ToastPath -ChildPath $ToastPSFile

        #Create Trigger for eacdh time in $ToastTime
        $Task_Triggers = @()
        Foreach ($TaskTime in $TaskTimes) {
            $Task_Expiry = $TaskTime.AddSeconds(21600).ToString('s') #Task Expires after 6 hours
            $Task_Trigger = New-ScheduledTaskTrigger -Once -At $TaskTime
            $Task_Trigger.EndBoundary = $Task_Expiry
            $Task_Triggers += $Task_Trigger
        }
        
        $Task_Principal = New-ScheduledTaskPrincipal -GroupId "S-1-5-32-545" -RunLevel Limited
        $Task_Settings = New-ScheduledTaskSettingsSet -Compatibility V1 -DeleteExpiredTaskAfter (New-TimeSpan -Seconds 600) -AllowStartIfOnBatteries
        $Task_Action = New-ScheduledTaskAction -Execute "C:\WINDOWS\system32\WindowsPowerShell\v1.0\PowerShell.exe" -Argument "-NoProfile -WindowStyle Hidden -File ""$NewToastFile"" -ToastGUID ""$ToastGUID"""
        $New_Task = New-ScheduledTask -Description "Toast_Notification_$($ToastGuid) Task for user notification. Title: $($ToastTitle) :: Event:$($ToastText) :: Source Path: $($ToastPath) " -Action $Task_Action -Principal $Task_Principal -Trigger $Task_Triggers -Settings $Task_Settings
        Register-ScheduledTask -TaskName "Toast_Notification_$($ToastGuid)" -InputObject $New_Task

        #Create Reg key to flag Proactive Remediation as successful
        New-Item -Path "HKLM:\Software\!ProactiveRemediations" -ErrorAction SilentlyContinue
        New-ItemProperty -Path "HKLM:\Software\!ProactiveRemediations" -Name "20H2NotificationSchTaskCreated" -Type DWord -Value 1 -ErrorAction SilentlyContinue
    }
	
    #Run the toast if the script is running in the context of the Logged On User
    If (!(([System.Security.Principal.WindowsIdentity]::GetCurrent()).Name -eq "NT AUTHORITY\SYSTEM")) {
		
        $Log = (Join-Path $ENV:Windir "Temp\$($ToastGuid).log")
        Start-Transcript $Log

        #Get logged on user DisplayName
        #Try to get the DisplayName for Domain User
        $ErrorActionPreference = "Continue"
		
        Try {
            Write-Output "Trying Identity LogonUI Registry Key for Domain User info..."
            Get-Itemproperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Authentication\LogonUI" -Name "LastLoggedOnDisplayName" -ErrorAction Stop | out-null
            $User = Get-Itemproperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Authentication\LogonUI" -Name "LastLoggedOnDisplayName" | Select-Object -ExpandProperty LastLoggedOnDisplayName -ErrorAction Stop | out-null
			
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
        If ($Hour -lt 12) { $CustomHello = "Good Morning $($Firstname), $ToastTitle" }
        ElseIf ($Hour -gt 16) { $CustomHello = "Good Evening $($Firstname), $ToastTitle" }
        Else { $CustomHello = "Good Afternoon $($Firstname), $ToastTitle" }
		
        #Load Assemblies
        [Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime] | Out-Null
        [Windows.Data.Xml.Dom.XmlDocument, Windows.Data.Xml.Dom.XmlDocument, ContentType = WindowsRuntime] | Out-Null
		
        #Build XML ToastTemplate 
        [xml]$ToastTemplate = @"
<toast duration="$ToastDuration" scenario="$ToastScenario">
    <visual>
        <binding template="ToastGeneric">
            <text>$CustomHello</text>
            <text>$ToastText</text>
            <text placement="attribution">$Signature</text>
            <image placement="hero" src="$HeroImage"/>
            <image placement="appLogoOverride" hint-crop="circle" src="$BadgeImage"/>
        </binding>
    </visual>
    <audio src="ms-winsoundevent:notification.default"/>
</toast>
"@
		
        #Build XML ActionTemplate 
        [xml]$ActionTemplate = @"
<toast>
    <actions>
        <action arguments="dismiss" content="Dismiss" activationType="system"/>
    </actions>
</toast>
"@
		
        #Define default actions to be added $ToastTemplate
        $Action_Node = $ActionTemplate.toast.actions
		
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
#endregion RegionName

#region ScriptRunningCode
	
Display-ToastNotification

#Endregion ScriptRunningCode
```

### Proactive Remediation

1. In the MEM Admin Centre, navigate to **Reports > Endpoint analytics** and click **Create script** package

<figure>

![](/images/2021/06/image-1024x402.png)

<figcaption>

Create a Proactive remediation

</figcaption>

</figure>

2\. Enter a **Name** and click **Next**

<figure>

![](/images/2021/06/image-1-961x1024.png)

<figcaption>

Enter a script name

</figcaption>

</figure>

3\. Select you **Detection** and **Remediation** script and toggle to **Run script in 64-bit PowerShell** and select **Next**

<figure>

![](/images/2021/06/image-2-965x1024.png)

<figcaption>

Upload your scripts

</figcaption>

</figure>

4\. On the **Assignments** blade, select the group of devices to deploy the scrips to

![](/images/2021/06/image-3-1024x433.png)

5\. Edit the proactive remediation schedule. Click the 3 dots and choose **Edit**

![](/images/2021/06/image-4-1024x153.png)

6\. Select **Once** from the **Frequency** list and choose the appropriate date to run the proactive remediation. The date should match the same date you specified in your detection script

![](/images/2021/06/image-5.png)

**Tip:** Select a time well in advance of the trigger times in the scheduled task

7\. Click **Next** and **Create**

### Results

Monitor the Proactive Remediation

![](/images/2021/06/image-7-1024x244.png)

![](/images/2021/06/image-8.png)

![](/images/2021/06/image-9-1024x322.png)

On the client a scheduled task is created with the triggers you specified.

![](/images/2021/06/image-11-1024x373.png)

A registry value is also added to satisfy the proactive remediation detection method

```
"HKLM:\Software\!ProactiveRemediations" -Name "20H2NotificationSchTaskCreated"
```

Toast Notifications will pop at the trigger intervals you specified

![](/images/2021/06/image-13.png)

### Summary

This was a pretty specific use case where the customer wanted multiple toast notifications to occur at specific times of the day to remind users to leave their computers on.

I don't expect you to have the exact same requirement but I wanted to highlight how versatile Proactive Remediations are. I really like that we can fire the same toast notification multiple times to "get our message across" by creating multiple triggers in our Toast Notification scheduled task. If the user dismisses the first notification the next trigger will fire a new notification to reinforce your message.

Let me know how you are using proactive remediations in your environment!

Thanks to Maurice for previously tweaking the toast notification to pull the toast images from a URL - this makes the toast solution very versatile.

Thanks to Mark Stoop for making the photo for this blog available freely on @unsplash