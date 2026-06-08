---
title: "Installing the OneDrive Sync Client in \"Per-Machine\" mode during your Task Sequence for a lightening fast \"first logon\" experience"
date: 2019-06-24
categories:
  - "Microsoft"
  - "Office 365"
  - "OneDrive"
  - "Scripts"
  - "Windows 10"
tags: ["onedrive", "silent-login", "sync-client", "task-sequence"]
---

### Background

One of the things I have been trying to improve is the users "first logon" experience in Windows 10. Waiting for the OneDrive sync client to "do its thing" reminded me of that one kid in the class that could be awesome if they tried harder. After the user profile is created (another post coming soon on tweaking the speed of this), OneDriveSetup.exe was called from the Default User Hive "Run" key. If OneDrive wasn't installed in the User's Profile (unlikely for a new profile), it would go and throw the binaries in %localappdata%, check for updates, twiddle its thumbs and eventually download some files or stubs.

<!--more-->

**What is wrong with waiting?**

Maybe our users have different expectations. "We want everything and we want it now" are the user chants that drift into our team - with rhythmic resemblance to war drums being beaten from a civilization who have just caught their first sniff of hot gravy.

An awesome OneDrive feature that now demands we make files available ASAP is "Known Folder Move" (KFM). This feature lets you redirect your users Documents, Pictures, and Desktop folder to OneDrive automatically. The Desktop is a pretty obvious thing when you log on. If your users files aren't there within a minute you're gonna be hunted down.

If you have user profile management or a "one user one laptop" policy then your users might forgive you for a one off, slow logon. Without the aforementioned, in a shared computing environment, where users hop onto different PC's daily, you want your users to be logged in and working fast..the seconds and minutes count!

**Solution**

After tweaking in the lab, I have observed a method that automatically signs the user into OneDrive and completes KFM in under 20 seconds. Let me show you how I did it. Pay particular attention to **[Section 3](#3)**

In this post we will cover:-

1. [**Import OneDrive Group Policy Templates**](#1)
2. **[GPO Settings for OneDrive Silent Logon and](#1) [](#2)[KFM](#1)**
3. **[Removing the reference to C:\\Windows\\SysWOW64\\OneDriveSetup.exe](#3)**
4. **[Creating an SCCM Application for the Machine Wide OneDrive Sync Client](#4)**
5. **[Deploying the Machine Wide OneDrive Sync Client during a Task Sequence](#5)**

### 1\. **Import OneDrive Group Policy Templates**

Before we can set Group Policy settings for OneDrive, we have to import the OneDrive templates into our Group Policy Central Store. To get the templates:-

1 . Download and install the latest OneDrive Sync Client (normal user installation is fine, we will look at the machine wide installer later)  
  
[https://go.microsoft.com/fwlink/?linkid=248256](https://go.microsoft.com/fwlink/?linkid=844652) (Production)  
  
2 . Navigate to the following folder **%localappdata%\\Microsoft\\OneDrive\\BuildNumber\\adm** where **BuildNumber** is the version of OneDrive you have just installed

3 . Copy the OneDrive.admx file into your domain Central Store "\\_**domain**_\\sysvol\\**domain**\\Policies\\PolicyDefinitions" folder

4 . Copy the OneDrive.adml file into your domain Central Store "\\_**domain**_\\sysvol\\**domain**\\Policies\\PolicyDefinitions\\en-us" folder \*

\* If you require a different language for your Group Policy Editor, copy the the relevant language folder to "\\_**domain**_\\sysvol\\**domain**\\Policies\\PolicyDefinitions " instead

### 2\. **GPO Settings for OneDrive Silent Logon and KFM** **[⏏](#NavMenu)**

Below are the typical settings I use, in an Enterprise, when a customer requires Silent Logon and enforcement of KFM

#### **Computer Configuration**

**Policy:** Allow syncing OneDrive accounts for only specific organizations  
**Setting:** Tenant ID = "<Tenant ID>"  
**Explanation:** This setting lets you prevent users from easily uploading files to other organizations by specifying a list of allowed tenant IDs. Your Tenant ID can be found in Azure Active Directory

![](/images/2019/06/onedrive_3-1024x554.jpg)

**Policy:** Silently move Windows known folders to OneDrive  
**Setting:** Tenant ID = "<Tenant ID>", Show Notification = "Yes"  
**Explanation:** This setting lets you redirect known folders to OneDrive without any user interaction

**Policy:** Silently sign in users to the OneDrive sync client with their Windows credentials  
**Setting:** Enabled  
**Explanation:** This setting lets you silently sign in users to the OneDrive sync client with their Windows credentials

**Policy:** Use OneDrive Files On-Demand  
**Setting:** Enabled  
**Explanation:** This setting lets you control whether OneDrive Files On-Demand is enabled for your organization

#### **User Configuration**

**Policy:** Prevent users from changing the location of their OneDrive folder  
**Setting:** Value Name = "<Tenant ID>", Value = "1"  
**Explanation:** This setting lets you block users from changing the location of their OneDrive - {organization name} folder during setup of the OneDrive sync client

### 3\. **Removing the reference to C:\\Windows\\SysWOW64\\OneDriveSetup.exe** **[⏏](#NavMenu)**[](#NavMenu)

By default, the native "C:\\Windows\\SysWOW64\\OneDriveSetup.exe" binary is run at logon when a new user profile is created. Lets load the "C:\\Users\\Default\\NTUser.dat" hive, in "HKEY\_USERS" as "**DefaultHive**" to have a peek at where this happens.

Navigate to "HKEY\_USERS\\**DefaultHive**\\Software\\Microsoft\\Windows\\CurrentVersion\\Run"

<figure>

[![](/images/2019/06/onedrive_4.jpg)](blob:https://byteben.com/08e71efd-5808-4a17-b39f-fb03323ef445)

<figcaption>

Value for OneDriveSetup in the Default User Hive

</figcaption>

</figure>

You will see "OneDriveSetup" with a value of "C:\\Windows\\SysWOW64\\OneDriveSetup.exe /thfirstsetup"

When this runs for the newly created profile, it will copy the OneDrive binaries into %localappdata% for that new user.

**Whats New?**

The latest OneDrive Sync Client now supports the "/AllUsers" switch which installs the OneDrive binaries into "C:\\Program Files (x86)" - a single binary for all OneDrive users on a machine.

When you install the OneDrive Sync Client with the /AllUsers switch, a new value is created in the RunOnce key, within the Default User Hive under "HKEY\_USERS\\**DefaultHive**\\Software\\Microsoft\\Windows\\CurrentVersion\\RunOnce"

<figure>

[![](/images/2019/06/onedrive_5.jpg)](blob:https://byteben.com/53749326-c237-4050-afce-958ca000b9cd)

<figcaption>

Value for OneDrive in the Default User Hive after installing with the "AllUsers" switch

</figcaption>

</figure>

**Considerations**

You may be fooled into thinking the machine wide startup reference replaces the other "OneDriveSetup.exe" value for the baked in Sync Client . No, notice the two keys are different!

"C:\\Windows\\SysWOW64\\OneDriveSetup.exe" reference for the baked in OneDrive binary:-

_HKEY\_USERS\\**DefaultHive**\\Software\\Microsoft\\Windows\\CurrentVersion\\Run_ **_/v OneDriveSetup_**

"C:\\Program Files (x86)\\Microsoft OneDrive\\OneDriveSetup.exe" reference for the machine wide OneDrive binary:-

_HKEY\_USERS\\**DefaultHive**\\Software\\Microsoft\\Windows\\CurrentVersion\\Run_Once _**/v OneDrive**_

Do we really need both OneDriveSetup.exe's running at the same time? Will this cause a disturbance in the Matrix?

#### **Solution**

If you have been installing the new OneDrive Sync Client with the "/AllUsers" switch **AFTER** the user has logged in, perhaps with a user targeted deployment from SCCM, the "_HKEY\_USERS\\DefaultHive\\Software\\Microsoft\\Windows\\CurrentVersion\\Run_ **_/v OneDriveSetup_**" key would have already initiated the binaries to be installed in the users profile. After the binaries installed, OneDrive would then attempt an update as the OneDriveSetup.exe in the "C:\\Windows\\SysWOW64" folder would be superseded (unless you are updating your WIM on a regular basis). Some time later, after an SCCM Client Policy refresh, the OneDrive "Machine Wide" installer would have been deployed. Now OneDrive will be installed in "C:\\Program Files (x86)\\Microsoft OneDrive" and the individual binaries removed from the users profile...what a lot of work!

Until i fully understand how the two startup references in the Default User Hive can co-exist without affecting the OneDrive startup speed for users - I am going to remove the reference to the baked in "C:\\Windows\\SysWOW64\\OneDriveSetup.exe"

To do this, we will use some PowerShell to mount the Default User Hive from "C:\\Users\\Default\\NTUser.dat" and delete the value from the Run key. We will use the **New-PSDrive** cmdlet to allow us to modify a value in the HKEY\_USERS root key of the Hive. We will then run this script during our Task Sequence or WIM maintenance\*  
  
\* If you haven't seen me mention this before go and take a look at OSBuilder to maintain your WIM! [https://www.osdeploy.com/osbuilder/overview](https://www.osdeploy.com/osbuilder/overview)

The following script can be found on my GitHub page [https://github.com/byteben/OneDrive/blob/master/Remove-OneDriveSetup\_RunKey.ps1](https://github.com/byteben/OneDrive/blob/master/Remove-OneDriveSetup_RunKey.ps1)

```
#Create PSDrive for HKU
New-PSDrive -PSProvider Registry -Name HKUDefaultHive -Root HKEY_USERS

#Load Default User Hive
Reg Load "HKU\DefaultHive" "C:\Users\Default\NTUser.dat"

#Set OneDriveSetup Variable
$OneDriveSetup = Get-ItemProperty "HKUDefaultHive:\DefaultHive\Software\Microsoft\Windows\CurrentVersion\Run" | Select -ExpandProperty "OneDriveSetup"

#If Variable returns True, remove the OneDriveSetup Value
If ($OneDriveSetup) { Remove-ItemProperty -Path "HKUDefaultHive:\DefaultHive\Software\Microsoft\Windows\CurrentVersion\Run" -Name "OneDriveSetup" }

#Unload Hive
Reg Unload "HKU\DefaultHive\"

#Remove PSDrive HKUDefaultHive
Remove-PSDrive "HKUDefaultHive"
```

### Putting it all together

Let us put these pieces of the puzzle together. We will deploy the new machine wide OneDrive Sync client during our Task Sequence and remove the reference to C:\\Windows\\SysWOW64\\OneDriveSetup.exe for when a new profile is created.

### 4\. **[Creating an SCCM Application for the Machine Wide OneDrive Sync Client](https://byteben.com/bb/wp-admin/post.php?post=1953&action=edit#4)** **[⏏](#NavMenu)**

1 . Download the OneDrive Sync Client to your deployment share (Sync client must be build 19.043.0304.0006 or later to support a machine wide installation). The latest Production client can be found here:- 
  
[https://go.microsoft.com/fwlink/?linkid=248256](https://go.microsoft.com/fwlink/?linkid=844652)

2 . Create a new Application in SCCM. **Software Library > Applications > Create Application**

<figure>

[![](/images/2019/06/onedrive_6.jpg)](blob:https://byteben.com/e29b2b69-4bec-4303-935d-b7eca8b49457)

<figcaption>

Create Application

</figcaption>

</figure>

3 . Choose **Manually specify the application information** and click **Next**

<figure>

[![](/images/2019/06/onedrive_7.jpg)](blob:https://byteben.com/681af9b7-6d5c-4e63-a9d7-2d1c3a5c7121)

<figcaption>

Choose **Manually specify the application information** and click **Next**

</figcaption>

</figure>

4 . Enter the following details:-

**Name:** OneDrive  
**Publisher:** Microsoft  
**Software Version:** 19.086.0502.0006 (the version you downloaded in step 1)  
  
Click **Next**

<figure>

[![](/images/2019/06/onedrive_8.jpg)](/images/2019/06/onedrive_8.jpg)

<figcaption>

Enter Application Details

</figcaption>

</figure>

5 . Choose a nice icon for the Application Catalog and click **Next**

<figure>

[![](/images/2019/06/onedrive_9.jpg)](blob:https://byteben.com/02fe8b63-7add-468d-8e0b-031eb5babbae)

<figcaption>

Choose a decent icon for the Application Catalog and click **Next**

</figcaption>

</figure>

6 . Click **Add** to create a new deployment type

<figure>

[![](/images/2019/06/onedrive_10.jpg)](/images/2019/06/onedrive_10.jpg)

<figcaption>

Click **Add** to create a new deployment type

</figcaption>

</figure>

7 . Choose **Manually specify the deployment information** and click **Next**

<figure>

![](/images/2019/06/onedrive_11.jpg)

<figcaption>

Choose **Manually specify the deployment information** and click **Next**

</figcaption>

</figure>

8 . Enter an Application **Name** and click **Next**

<figure>

[![](/images/2019/06/onedrive_12.jpg)](/images/2019/06/onedrive_12.jpg)

<figcaption>

Enter an Application **Name** and click **Next**

</figcaption>

</figure>

9 . Enter the following details:-

**Content Location:** \\\\server\\share\\Onedrive\\19.086.0502.0006  
**Installation Program:** OneDriveSetup.exe /AllUsers  
**Uninstall Program:** %ProgramFiles%\\Microsoft OneDrive\\19.086.0502.0006\\OneDriveSetup.exe /uninstall /allusers (replace the version number with the version of Sync Client you downloaded in step 1)  
**Run installation and uninstall program as 32-bit process on 64-bit clients:** Enabled

Click **Next**

<figure>

![](/images/2019/06/onedrive_13.jpg)

<figcaption>

Enter the Application Details and click **Next**

</figcaption>

</figure>

10 . Click **Add Clause** to specify a Detection Rule

![](/images/2019/06/onedrive_14.jpg)

11 . As per [https://docs.microsoft.com/en-us/onedrive/per-machine-installation](https://docs.microsoft.com/en-us/onedrive/per-machine-installation) we will specify a Registry item for the Application Detection method.  
  
Enter the following details:-

**Setting Type:** Registry  
**Hive:** HKEY\_LOCAL\_MACHINE  
**Key:** SOFTWARE\\Microsoft\\OneDrive  
**Value:** Version  
**This registry key is associated with a 32-bit application on 64-bit systems:** Enabled  
**Data Type:** Version  
**This registry setting must satisfy the following rule to indicate the presence of this application:** Enabled  
**Operator:** Greater than or equal to  
**Value:** 19.086.0502.0006 (version should be the same as the version you are installing (see step 1)

Click **OK**

<figure>

[![](/images/2019/06/onedrive_15.jpg)](/images/2019/06/onedrive_15.jpg)

<figcaption>

Enter the above settings for your Detection Rule

</figcaption>

</figure>

12 . Click **Next**

13 . For the User Experience, enter the following details:-

**Installation Behavior:** Install for system  
**Logon Requirement:** Whether or not a user is logged on  
**Installation program visibility:** Hidden

Click **Next**

<figure>

[![](/images/2019/06/onedrive_16.jpg)](/images/2019/06/onedrive_16.jpg)

<figcaption>

Enter the above settings for the User Experience

</figcaption>

</figure>

14 . Click **Next** on requirements

15 . Click **Next** on dependencies

16 . Confirm Settings and click **Next**

17 . Click **Close** on the Deployment Type wizard

18 . Click **Next**

19 . Click **Next**

20 . Click **Close**

### 5 . **Deploying the Machine Wide OneDrive Sync Client during a Task Sequence** **[⏏](#NavMenu)**

1 . Edit the OSD Task Sequence where you want to deploy the OneDrive Sync Client "Machine Wide" installer

2 . At the step after the Operating System has booted from WinPE Phase into the Current OS, click **Add > Software > Install Application**

<figure>

[![](/images/2019/06/onedrive_17.jpg)](/images/2019/06/onedrive_17.jpg)

<figcaption>

Add an "Install Application" step in your Task Sequence

</figcaption>

</figure>

3 . Enter a **Name** for this Task Sequence step and then click the **New** (yellow star) icon

<figure>

[![](/images/2019/06/onedrive_18.jpg)](/images/2019/06/onedrive_18.jpg)

<figcaption>

Enter Task Sequence Step Name and click "New"

</figcaption>

</figure>

4 . Navigate to the Application we created previously. Select the box beside the application and click **OK**

<figure>

[![](/images/2019/06/onedrive_19.jpg)](/images/2019/06/onedrive_19.jpg)

<figcaption>

Select The Application and click **OK**

</figcaption>

</figure>

5 . Ensure the "Install Application" step has been created successfully and click **Apply**

<figure>

![](/images/2019/06/onedrive_20.jpg)

<figcaption>

Ensure the "Install Application" step has been created successfully and click **Apply**

</figcaption>

</figure>

6 . Next we are going to add a PowerShell script to our Task Sequence as mentioned earlier to removed the reference to the baked in OneDriveSetup.exe in "C:\\Windows\\SysWOW64\\OneDriveSetup.exe". Highlight the Install Application step we created previously and select **Add > General > Run PowerShell Script**

<figure>

[![](/images/2019/06/onedrive_22.jpg)](/images/2019/06/onedrive_22.jpg)

<figcaption>

Select **Add > General > Run PowerShell Script**

</figcaption>

</figure>

7 . Enter a **Name** for this Task Sequence step and then select **Enter a PowerShell Script**

<figure>

[![](/images/2019/06/onedrive_23.jpg)](/images/2019/06/onedrive_23.jpg)

<figcaption>

Enter a **Name** for this Task Sequence step and then select **Enter a PowerShell Script**

</figcaption>

</figure>

8 . Click **Add Script**

9 . Enter the following script

```
#Create PSDrive for HKU
New-PSDrive -PSProvider Registry -Name HKUDefaultHive -Root HKEY_USERS

#Load Default User Hive
Reg Load "HKU\DefaultHive" "C:\Users\Default\NTUser.dat"

#Set OneDriveSetup Variable
$OneDriveSetup = Get-ItemProperty "HKUDefaultHive:\DefaultHive\Software\Microsoft\Windows\CurrentVersion\Run" | Select -ExpandProperty "OneDriveSetup"

#If Variable returns True, remove the OneDriveSetup Value
If ($OneDriveSetup) { Remove-ItemProperty -Path "HKUDefaultHive:\DefaultHive\Software\Microsoft\Windows\CurrentVersion\Run" -Name "OneDriveSetup" }

#Unload Hive
Reg Unload "HKU\DefaultHive\"

#Remove PSDrive HKUDefaultHive
Remove-PSDrive "HKUDefaultHive"
```

10 . Click **OK**

11 . Change the **PowerShell execution policy** to **Bypass**

12\. Click **Apply**

### Summary

The OneDrive Sync Client should be deployed "Machine Wide" in your Enterprise. No body likes to manage applications installed in the users profile (falls on knees.... MS Teams please follow suite soon).

If you don't install the Sync Client during your Task Sequence (or as part of your WIM maintenance) then the experience for your user, who logs on for the first time, will be less than desirable.

When using the method outlined above, in my experience, OneDrive is now available in less than 20 seconds for the new user, including Known Folders being available.  
  
The following reading is recommended:-

[https://docs.microsoft.com/en-us/onedrive/per-machine-installation](https://docs.microsoft.com/en-us/onedrive/per-machine-installation)  
[https://docs.microsoft.com/en-us/onedrive/redirect-known-folders](https://docs.microsoft.com/en-us/onedrive/redirect-known-folders)  
[https://support.office.com/en-us/article/onedrive-release-notes-845dcf18-f921-435e-bf28-4e24b95e5fc0](https://support.office.com/en-us/article/onedrive-release-notes-845dcf18-f921-435e-bf28-4e24b95e5fc0)

I did shout on Twitter how i removed the reference to the baked in OneDriveSetup.exe from the Default User Hive. Again, i am not sure if this is required but it felt like good practice to me to tidy this up (please someone correct me if this is not required).

https://twitter.com/byteben/status/1141350554112839681

In an upcoming post, we will look at moving your browser favorites to OneDrive too!