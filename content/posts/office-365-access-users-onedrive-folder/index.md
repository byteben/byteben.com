---
title: "Office 365 - Access a Users OneDrive Folder"
date: 2018-10-15
categories:
  - "Microsoft"
  - "Office 365"
tags: ["access-files", "office-365", "onedrive", "personal-site", "sharepoint", "site-collection-owner"]
---

I thought I would dig a little deeper on this cool little feature in the Microsoft 365 Admin Center. Administrators are able to select a user and "Access" that users OneDrive files. Cool for a number of scenarios, so Microsoft believe to create this feature, but it does comes with a caveat. (Read post before implementing). Let's first see how, as an Administrator, we can do this.<!--more-->

1\. Log into the Microsoft 365 Admin Center for your tenant at [https://admin.microsoft.com/AdminPortal](https://admin.microsoft.com/AdminPortal)

2\. Search for the user whose OneDrive you need to access.

![](/images/2018/10/Access-a-Users-OneDrive-Folder_1.jpg)

3\. Scroll down to "OneDrive Settings" and click "Access Files"

![](httsp://byteben.com/bb/images/2018/10/Access-a-Users-OneDrive-Folder_2.jpg)

4\. This will reveal a hyperlink to the users OneDrive folder. Click it to Open OneDrive in your Browser to access their files

![](/images/2018/10/Access-a-Users-OneDrive-Folder_3.jpg)

**WAIT** - You did read earlier there was a caveat doing this?

You have now just added the account you signed in to the Microsoft 365 Admin Center as a "Site Collection Owner" on the User's Personal Sharepoint Site (OneDrive). Not bad if you intended to just do a quick file copy for the user but do you really want to leave that permission there? When they look in their Documents folder they will see you have permissions on their OneDrive files. Not too tidy.

Lets have a look in SharePoint Online to see the permission we just created.

1\. navigate to **https://<tenant>-admin.sharepoint.com** or open the SharePoint Admin Center from the Microsoft 365 Admin Center screen.

2\. Click "User Profiles" - Manage User Profiles"

![](httsp://byteben.com/bb/images/2018/10/Access-a-Users-OneDrive-Folder_4.jpg)

3\. Search for the user we just applied the Admin permission to, click "Find", click the drop down list icon and choose "Manage Site Collection Owners"

![](/images/2018/10/Access-a-Users-OneDrive-Folder_5.jpg)

4\. You can see here the admin account that I used in the Microsoft 365 Admin Center to Access "Ben Whitmore's" OneDrive is now a Site Collection Administrator (Obfuscated in red)

![](/images/2018/10/Access-a-Users-OneDrive-Folder_6.jpg)

After you have finished Accessing the Users OneDrive files, simply remove your permission from the "Site Collection Administrators" box (Step 4) - keeps things nice and tidy and the user wont question why your account has permissions on their OneDrive files.

In the next Post we will look at adding and removing Access to a users OneDrive folder using PowerShell

https://byteben.com/bb/modify-onedrive-site-admins-with-powershell/