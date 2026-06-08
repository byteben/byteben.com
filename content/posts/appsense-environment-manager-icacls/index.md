---
title: "AppSense Environment Manager - Using ICACLS / WIN7 IE Print Preview Blank Page"
date: 2013-02-12
categories:
  - "AppSense"
  - "AppSense - Environment Manager - Scripts"
  - "AppSense Environment Manager"
  - "AppSense Environment Manager Configurations"
  - "Microsoft"
tags: ["appsense", "appsense-environmentmanager", "appsense-environmentmanager-configurations", "icacls", "ie-print-preview", "kb973479"]
---

Hey, Ben here. I'm sitting at home today nursing a poorly baby with a fever so i thought i'd throw this quick article together out on how to use Microsoft ICACLS to set folder/file permissions using AppSense Environment Manager. ICACLS is a neat tool included in Windows 7/Server 2008 OS that allows you to view and modify the access control lists for files and folders on your NTFS file system.

We use ICACLS all of the time in our environment, especially when introducing new users to the system for the first time. We use it to build home drives and setup their personalized user environment PUE..thats neat..PUE..just made that acronym up! :)

<!--more-->

Here is quite a common issue for new users on a Windows 7 environment and how we used ICACLS in EM to overcome it. I think it is more common when using mandatory profiles (or so it seems when I have seen others come across the same problem). Here is the Microsoft KB, we are reproducing method 5 in the following steps to fix this problem [http://support.microsoft.com/kb/973479](http://support.microsoft.com/kb/973479)

Basically, the %temp%\\Low folder either does not get created or the permissions are not correct when the profile is created. The most obvious result of this is that Web pages are blank when you try and do print preview in Internet Explorer (basically because you don't have permission to where the preview pages are spawned..%temp%\\low).

A simple fix is to check to see if this folder exists, if it doesn't create it, if it does then reset the folder permission to allow the user access to it. See below:-

[](http://byteben.com/bb/images/2013/02/ieprint.jpg)[![AppSense Environment Manager - Using ICACLS / Print Preview Blank Page](/images/2013/02/ieprint.jpg)](http://byteben.com/bb/images/2013/02/ieprint.jpg)

Here is a closer look at the icacls command to set the folder integrity level on the %temp%\\low folder

[![AppSense Environment Manager - Using ICACLS / Print Preview Blank Page](/images/2013/02/ieprint2.jpg)](http://byteben.com/bb/images/2013/02/ieprint2.jpg)

And here is the command we use if you fancy doing a bit of copy and pasting:-

```
%systemroot%\system32\icacls.exe %temp%\Low /setintegritylevel (OI)(CI)low
```

You can see that I have the check box selected "Do Not Create Window" otherwise the user just gets lots of dos boxes blinking all over the place at logon which looks a bit untidy.

And there it is, a simple example of how to get EM to run ICACLS with a bit of conditional query too. Oh, and you will now be able to see pages when you choose print preview in Internet Explorer too..what an added bonus!

## AppSense Environment Manager - Using ICACLS / IE Print Preview Blank Page

### AppSense Environment Manager - Using ICACLS / IE Print Preview Blank Page