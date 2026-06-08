---
title: "Personalize Adobe Reader with AppSense"
date: 2013-06-16
categories:
  - "AppSense"
  - "AppSense Environment Manager"
  - "AppSense Environment Manager Configurations"
tags: ["csidl_common_appdataadobearm", "acrord32-exe", "adobe-reader", "appsense", "appsense-environmentmanager", "appsense-environmentmanager-configurations"]
---

Adobe Reader can be personalized using AppSense Environment Manager. Here are some simple steps to create a new User Application for Adobe Reader in the Environment Manager Console and a tip to keep your SQL admins happy. By default acrord32.exe is in the default blacklist for monitored applications (thanks Bryan @techbury for prompting me)

<!--more-->

Here are some steps and narratives:-

1\. First thing we need to do is open Environment Manager.

2\. Next click on the User Personalization pane (circled below) and connect to your personalization server.

[![Personalize Adobe Reader with AppSense](/images/2013/06/Personalize-Adobe-Reader-with-AppSense-3.jpg)](http://byteben.com/bb/images/2013/06/Personalize-Adobe-Reader-with-AppSense-3.jpg)

3\. Ok, now drill down the tree to "Applications" - "Application Categories" and then highlight "User".

4\. Click on the "Add Application" icon on the toolbar.

[![Personalize Adobe Reader with AppSense](/images/2013/06/Personalize-Adobe-Reader-with-AppSense-4.jpg)](http://byteben.com/bb/images/2013/06/Personalize-Adobe-Reader-with-AppSense-4.jpg)

5\. Great, now we just need to enter the details of the application we want EM to start personalizing, in this case it is acrord32.exe. Enter in the following information:-

[![Personalize Acrobat Reader with AppSense](/images/2013/06/Personalize-Adobe-Reader-with-AppSense.jpg)](http://byteben.com/bb/images/2013/06/Personalize-Adobe-Reader-with-AppSense.jpg)

6\. So, after clicking "Ok" we now have a new user application defined in our User Application Categories on the EM console.

7\. Next we need to specify any particular folders we want to be included or excluded for this user application. From personal experience there is one particular folder I DO NOT want to commit to the database for this application. That folder is:-

```
{CSIDL_COMMON_APPDATA}\Adobe\ARM
```

This particular folder contains application updates that the application downloads during the user session so Adobe can perform self updates. We don't want to save these into our DB or the SQL guy is gonna get really annoyed at our DB size.

Highlight your new Adobe Reader application and enter the following information into the "Folders - Exclude" section.

[![Personalize Adobe Reader with AppSense](/images/2013/06/Personalize-Adobe-Reader-with-AppSense-2.jpg)](http://byteben.com/bb/images/2013/06/Personalize-Adobe-Reader-with-AppSense-2.jpg)

We also exclude (to keep thing ultra clean and because our user environment doesn't require it)

```
{CSIDL_PROFILE}\AppData\LocalLow\Adobe\Acrobat\10.0\Search
```

STOP - WAIT - ITS NOT OVER YET

Thanks Bryan @techbury for the reminder. Unless you disable bprotectedmode when personalizing acrord32.exe Adobe Reader will crash more times than original release of Windows Vista on a bad day.

Add the following key to disabled protected mode on startup for Reader X

```
HKLM\SOFTWARE\Policies\Adobe\Acrobat Reader\10.0\FeatureLockDown
Value: bProtectedMode
Type: REG_DWORD
Data: 0
```

Add the following key to disabled protected mode on startup for Reader XI

```
HKLM\SOFTWARE\Policies\Adobe\Acrobat Reader\11.0\FeatureLockDown
Value: bProtectedMode
Type: REG_DWORD
Data: 0
```

Don't forget to assign this application to the white-list in your Personalization Group/s. When the clients agent next syncs with personalization server they will see they have a new application to start personalizing. You can use persinfo /sync to force a sync with the PS if you really can't wait (persinfo is a great tool).

Hope this post has been useful.