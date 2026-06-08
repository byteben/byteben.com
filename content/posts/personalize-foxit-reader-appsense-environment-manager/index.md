---
title: "How to Personalize Foxit Reader with AppSense Environment Manager"
date: 2013-02-16
categories:
  - "AppSense"
  - "AppSense - Environment Manager - Scripts"
  - "AppSense Environment Manager"
  - "AppSense Environment Manager Configurations"
tags: ["adobe-preview-handler-problem-64bit", "appsense", "appsense-application-group", "appsense-environmentmanager", "appsense-environmentmanager-configurations", "appsense-user-applications", "foxit-reader"]
categories: ["appsense", "appsense-environmentmanager-scripts", "appsense-environmentmanager", "appsense-environmentmanager-configurations"]
---

Adobe have a nice - longstanding problem with their preview handler in the 64bit version of their reader. We installed Foxit Reader into our Gold Windows 7 64bit image which replaced the already installed Adobe preview handler. This worked a treat, our customers could now preview PDF documents in Explorer and the Microsoft Outlook 2010 preview pane. We needed to personalize the Foxit App with AppSense. In this blog Ill explain how to add a new App to personalization and some specific includes and excludes for Foxit Reader.<!--more-->

First thing to note is that we are using AppSense Environment Manager 8.3.1.57 (apologies if the screen shots vary from your version). Here are some steps and narratives:-

1\. First thing we need to do is open Environment Manager (Ill refer to it as EM for the rest of this blog).

2\. Next click on the User Personalization pane (circled below) and connect to your personalization server (Ill refer to this as PS)

[![How to Personalize Foxit Reader with AppSense Environment Manager](/images/2013/02/How-to-Personalize-Foxit-Reader-with-AppSense-Environment-Manager-1.jpg)](http://byteben.com/bb/images/2013/02/How-to-Personalize-Foxit-Reader-with-AppSense-Environment-Manager-1.jpg)

3\. Ok, now drill down the tree to "Applications" - "Application Categories" and then highlight "User".

4\. Click on the "Add Application" icon on the toolbar.

[![How to Personalize Foxit Reader with AppSense Environment Manager](/images/2013/02/How-to-Personalize-Foxit-Reader-with-AppSense-Environment-Manager-2.jpg)](http://byteben.com/bb/images/2013/02/How-to-Personalize-Foxit-Reader-with-AppSense-Environment-Manager-2.jpg)

5\. Great, now we just need to enter the details of the application we want EM to start personalizing, in this case it is Foxit Reader Enterprise 5.45. Enter in the following information:-

[![How to Personalize Foxit Reader with AppSense Environment Manager](/images/2013/02/How-to-Personalize-Foxit-Reader-with-AppSense-Environment-Manager-3.jpg)](http://byteben.com/bb/images/2013/02/How-to-Personalize-Foxit-Reader-with-AppSense-Environment-Manager-3.jpg)

NOTE: We only have one version of "Foxit Reader.exe" in our environment so there is no need for me to specify an application version in this case.

6\. So, after clicking "Ok" we now have a new user application defined in our EM console. The next step will be to create an Application Group.

7\. Highlight "Application Groups" and from the toolbar click the "Add Application Group" button.

[![How to Personalize Foxit Reader with AppSense Environment Manager](/images/2013/02/How-to-Personalize-Foxit-Reader-with-AppSense-Environment-Manager-4.jpg)](http://byteben.com/bb/images/2013/02/How-to-Personalize-Foxit-Reader-with-AppSense-Environment-Manager-4.jpg)

8\. In my example I am going to name this new Application Group "Foxit" IMPORTANT: You cannot call your "Application Group" the same as your recently defined user application. If you try and call it the same as an already defined item you will be prompted with a msg box to that effect.

9\. The next step is to assign our user defined application (Foxit Reader) to the "Foxit" Application Group. Simply highlight your newly created Application Group and choose "Add Application" from the toolbar. Select your user defined application from the available list (in this example I would select "Foxit Reader.exe" and click "Ok". Your new Application Group should look something like this:-

[![How to Personalize Foxit Reader with AppSense Environment Manager](/images/2013/02/How-to-Personalize-Foxit-Reader-with-AppSense-Environment-Manager-5.jpg)](http://byteben.com/bb/images/2013/02/How-to-Personalize-Foxit-Reader-with-AppSense-Environment-Manager-5.jpg)

10.Great. Our next job is tell AppSense what reg keys and file locations we definitely want to capture for this application. Click on the "Registry" tab. The screen will be split into two. The top half is titled "Include" and the bottom half "Exclude". Right clicking in either pane will allow you to include/exclude a registry key for your application group. In our example we are going to **"Include"** the following key:-

```
HKEY_CURRENT_USER\Software\Foxit Software\Foxit Reader 5.0
```

[![How to Personalize Foxit Reader with AppSense Environment Manager](/images/2013/02/How-to-Personalize-Foxit-Reader-with-AppSense-Environment-Manager-6.jpg)](http://byteben.com/bb/images/2013/02/How-to-Personalize-Foxit-Reader-with-AppSense-Environment-Manager-6.jpg)

11\. Next we need to specify any particular folders we want to be included or excluded for this Application Group. Now AppSense will automatically personalize any user appdata it sees the user change when they use this application and commit it to the database on the next application sync. From personal experience there is one particular folder I DO NOT want to commit to the database for this application. That folder is:-

```
 {CSIDL_APPDATA}\Foxit Software\Addon\Install
```

This particular folder contains any application update MSI's that the application downloads during the user session. We dont want to save these into our DB or the SQL guy is gonna get really annoyed at our DB size. Not only that, each time a user opens Foxit Reader they are going to be downloading these MSIs each time which will slow down application performance.

[![How to Personalize Foxit Reader with AppSense Environment Manager](/images/2013/02/How-to-Personalize-Foxit-Reader-with-AppSense-Environment-Manager-7.jpg)](http://byteben.com/bb/images/2013/02/How-to-Personalize-Foxit-Reader-with-AppSense-Environment-Manager-7.jpg)

12\. Ta da!! Thats it right? Not quite sailor! The last thing we need to do is assign our Application Group to our Personalization Group/s. Highlight your desired Personalization Group and select the "Whitelist" tab. Now right click in the "Application Groups" pane (lower half of the window) and choose "Add Application Group". Select your recently created application group (in our case it is Foxit") and click "Ok". Your Personalization Whitelist should now have your Application Group in it (see below).

[![How to Personalize Foxit Reader with AppSense Environment Manager](/images/2013/02/How-to-Personalize-Foxit-Reader-with-AppSense-Environment-Manager-8.jpg)](http://byteben.com/bb/images/2013/02/How-to-Personalize-Foxit-Reader-with-AppSense-Environment-Manager-8.jpg)

All done. When the clients agent next syncs with personalization server they will see they have a new application to start personalizing. You can use persinfo /sync to force a sync with the PS if you really can't wait.

Hope this post has been useful. I will do a post soon on how to install Foxit Reader Enterprise silently with some funky switches and how to get the Foxit ADMS into EM.

## How to Personalize Foxit Reader with AppSense Environment Manager

### How to Personalize Foxit Reader with AppSense Environment Manager