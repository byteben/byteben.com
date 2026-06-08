---
title: "Using scripts to evaluate Win32 app requirements - \"Require Chassis equals Laptop\""
date: 2020-10-01
categories:
  - "Intune"
  - "Microsoft"
  - "Scripts"
  - "Windows 10"
tags: ["app-requirements", "compliance", "ime", "intune-management-extension", "msintune", "powershell", "scripts-2", "win32apps"]
---

In this short post we will be looking at app requirements in the context of installing Win32 apps.

<!--more-->

## What are App Requirements?

App Requirements allow you to specify certain requirements are met before your app gets installed on your endpoint. If the requirements are not met the app will not install. Many admins create groups to target apps to users - this is great! But what if the user has a device that you know the app will not work on?

For example. The accounts department has a mix of users with laptops and PCs. We want to make software available to them but we know it will only work on a specific Windows version and if a certain registry key exists - this is where app requirements becomes so useful. We can target the accounts user group to make software available to them and only allow the app to install if certain requirements are met - we don't need to create different groups to target specific users in the accounts department.

There are some built in requirements you can choose from when creating your Win32 application. Lets explore them briefly.

![](/images/2020/09/image-1024x661.png)

**Operating System Architecture**  
Choose the architecture required to install the app  
Options: 32-bit or 64-bit

**Minimum operating system**  
Select the minimum operating system required to install the app  
Options: Windows 10 1607 / 1703 / 1709 / 1803 / 1809 / 1903 / 1909  
  
**Disk space required (MB)**  
Free space required on the system drive to install the app  
  
**Physical memory required (MB)**  
Physical memory required to install the app  
  
**Minimum number of logical processors required**  
The minimum number of logical processors required to install the app  
  
**Minimum CPU speed required (MHz)**  
Minimum CPU speed required to install the app  
  
As well as the options above you can also choose one of 3 extended requirements **File, Registry** and **Script**  
  
**File**

![](/images/2020/09/image-2-1024x516.png)

  
  
**Registry**

![](/images/2020/09/image-3-1024x502.png)

  
**Script**

![](/images/2020/09/image-4-1024x727.png)

## Script Example

In the following example, we will use a PowerShell script to check the Chassis type of the device. If the value returned indicates that it is a laptop, we will return success and the app requirement will be satisfied.

Script credit to [https://powershell.one/wmi/root/cimv2/win32\_systemenclosure](https://powershell.one/wmi/root/cimv2/win32_systemenclosure)

The script above mas modified to return 3 values which can be used in ConfigMgr / Intune. The out put of the script will be either **IsLaptop**, **IsDesktop** or **IsServer**

You can grab the modified script here [https://github.com/byteben/Windows-10/blob/master/Detect\_Chassis.ps1](https://github.com/byteben/Windows-10/blob/master/Detect_Chassis.ps1)

```
#Credit to https://powershell.one/wmi/root/cimv2/win32_systemenclosure
#Modified original script to output IsLaptop, IsDesktop, IsServer, IsOther to be used as a detection method
$Chassis = @{ 
  Name       = 'ChassisTypes'
  Expression = {
    $ChassisResult = foreach ($ChassisValue in $_.ChassisTypes) {
      switch ([int]$ChassisValue) {
        1 { 'IsOther' }
        2 { 'IsOther' }
        3 { 'IsDesktop' }
        4 { 'IsDesktop' }
        5 { 'IsDesktop' }
        6 { 'IsDesktop' }
        7 { 'IsDesktop' }
        8 { 'IsLaptop' }
        9 { 'IsLaptop' }
        10 { 'IsLaptop' }
        11 { 'IsLaptop' }
        12 { 'IsLaptop' }
        13 { 'IsOther' }
        14 { 'IsLaptop' }
        15 { 'IsDesktop' }
        16 { 'IsDesktop' }
        17 { 'IsOther' }
        18 { 'IsLaptop' }
        19 { 'IsOther' }
        20 { 'IsOther' }
        21 { 'IsLaptop' }
        22 { 'IsOther' }
        23 { 'IsServer' }
        24 { 'IsOther' }
        default { "$ChassisValue" }
      }
      
    }
    $ChassisResult
  }  
}

Get-CimInstance -ClassName Win32_SystemEnclosure | Select-Object $Chassis | foreach-object { $_.ChassisTypes }
```

## Adding a script as an app requirement

1 . In the Win32 app wizard, select the **requirements** tab and click **+Add**

![](/images/2020/09/image-5-1024x334.png)

2 . In the **Requirement type** field, choose **Script**

![](/images/2020/09/image-7-1024x713.png)

3 . Enter a name in the **Script name** field

![](/images/2020/09/image-6-1024x713.png)

4 . Browse to and select the app requirement script

![](/images/2020/09/image-8-1024x847.png)

5 . From the **Select output data type** drop down box, select **String**

6 . From the **Operator** drop down box, select **Equals**

7 . Enter **IsLaptop** in the value field

![](/images/2020/09/image-9-1024x222.png)

8 . Click **OK**

9 . Complete the rest of the WIn32 application configuration

10 . Review and save the WIn32 application

## Observing the app requirement behaviour

1 . Open the Company Portal on a device for a user you targeted with the app that satisfies the requirement i.e. IsLaptop

2 . Install the Win32 app

![](/images/2020/10/image.png)

The app installs as expected because the script output matched the app requirement

![](/images/2020/10/image-1.png)

3 . Now open the Company Portal on a device for a user you targeted with the app that does not satisfy the requirement i.e. IsDesktop

4 . Attempt to install the same Win32 app

![](/images/2020/10/image-2.png)

The app will not install because the app requirement has not been met. The script output was not the expected **IsLaptop**

![](/images/2020/10/image-3.png)

If we examine the **IntuneManagementExtension.log** file we can see the app requirement script block is passed

![](/images/2020/10/image-4-1024x653.png)

We can see the expected value of the script output

![](/images/2020/10/image-6.png)

As we move through the log we can see the detection logic is run first, does the app exist? **(1)**  
The app requirement rules are checked **(2)**  
The extended app requirement rules are checked **(3)**

![](/images/2020/10/image-5-1024x483.png)

## Summary

App requirements are a nice way to be able to target your apps to users and devices without having to be imaginative with Dynamic Membership in Azure AD Groups. In the example above we used a PowerShell script for the extended requirement to ensure the device was a laptop before the app was installed.

If you have any other imaginative examples of how you have used app requirements and scripting, let me know!