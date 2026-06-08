---
title: "Remove Built-in Windows 11 apps leveraging a Cloud-Sourced reference file"
date: 2022-08-08
categories: ["uncategorized"]
---

In this quick post we will be removing built-in Windows 11 apps, for all users, and optionally showing you how to leverage a "Cloud-Source" as a reference file to select apps for removal.

<!--more-->

## Introduction

### Appx Provisioned Packages - the evolution

There are many great examples of how to remove built-in Windows apps. I have been using a [script](https://msendpointmgr.com/2021/02/02/remove-built-in-apps-for-windows-10-version-20h2/) from my friend @nickolaja for a while and have modified it to reflect the additional built-in apps that appear in subsequent Windows 10 feature updates and also Windows 11.

Microsoft often include additional apps in each release of Windows, meaning admins need to update their appx removal scripts frequently. This is normally fine, but in environments that require all scripts to be signed - this can (and does) lead to frustration. "I can't sign off this dev ticket today boss until Jessica returns from the Maldives next week". It is unlikely that pending doom is invoked because Jessica was on leave, but you get my point.

Take me to the Maldives, I don't care about script signing

### A different way to introduce variables

I was chatting with @mauriced and @jankeskanke about this scenario and they, as always, had an interesting idea and perspective. What if we could change our script variables without having to re-sign the scripts each time...

Great Idea! In this post I will include a script to remove built-in apps from Windows 11, with the apps defined as an array within the script (the old fashioned way if you like). I will also share a version of the script where I will use a reference file hosted on GitHub to dynamically build the array of apps to remove. Your reference file could be hosted on Azure Blob or any other cloud storage provider. The reference file, a text file in this example, will allow me to dynamically update the list of apps I want to remove from my devices. Change my mind on what apps I want remove? I simply update the .txt file on GitHub - no need to re-sign or redistribute the script!

"Text file....Heresy! Use a JSON or XML!" I hear you cry. Well yes, fair point. You will see why I choose to use a .txt file later. It is really quick and simple to differentiate between which apps I want to remove and the apps I want to keep.

## Scripts

### Windows 11 App Removal Script

This script will remove built-in Windows 11 apps **without** using a Cloud source reference file. Instead, the apps to remove are explicitly defined in an array in the script.

<figure>

[![](/images/2022/06/image-4-1024x580.png)](/images/2022/06/image-4.png)

<figcaption>

Apps to Remove defined in an array

</figcaption>

</figure>

Simply modify the **$BlackListedApps** array list to include the appx provisioned packages you want to **remove** from the device. The full list of packages can be found in the comment block at the beginning of the script.

[Windows/Remove-Appx-AllUsers.ps1 at master · MSEndpointMgr/Windows (github.com)](https://github.com/MSEndpointMgr/Windows/blob/master/BuiltInApps/Remove-Appx-AllUsers.ps1)

### Windows 11 App Removal Script (Using Cloud Sourced reference file)

This script will remove built-in Windows 11 apps **with** a Cloud source reference file. If the app has a **#** prefixed in the reference file then we remove that built-in app.

<figure>

[![](/images/2022/06/image-6-1024x479.png)](/images/2022/06/image-6-1024x479.png)

<figcaption>

Reference File

</figcaption>

</figure>

The script will reference the **blacklist\_w11.txt** file in GitHub. Change this line to reflect the location of your reference file

<figure>

![](/images/2022/06/image-13-1024x99.png)

<figcaption>

Edit line 99 URL for Reference File

</figcaption>

</figure>

[](https://github.com/byteben/Windows-11/blob/main/BuiltInApps/Remove-Appx-AllUsers-CloudSourceList.ps1)[Windows/Remove-Appx-AllUsers-CloudSourceList.ps1 at master · MSEndpointMgr/Windows (github.com)](https://github.com/MSEndpointMgr/Windows/blob/master/BuiltInApps/Remove-Appx-AllUsers-CloudSourceList.ps1)

[](https://github.com/byteben/Windows-11/blob/main/BuiltInApps/blacklist_w11.txt)[Windows/blacklist\_w11.txt at master · MSEndpointMgr/Windows (github.com)](https://github.com/MSEndpointMgr/Windows/blob/master/BuiltInApps/blacklist_w11.txt)

## Script Overview

When either of the scripts above are distributed and run, the apps are removed from the device for **all** users. If you run the script(s) interactively, you will see the progress of the app removal.

<figure>

![](/images/2022/06/image-8.png)

<figcaption>

Removing Built-In apps

</figcaption>

</figure>

If you re-run the script after changing the reference file, the additional apps selected will be removed

<figure>

![](/images/2022/06/image-11-1024x620.png)

<figcaption>

Additional built-in apps removed

</figcaption>

</figure>

The script(s) can either packaged as Win32apps and distributed to devices. Win32apps are great because you can leverage Filters to accurately target your different device builds quickly. Remember to run the script in the System context so all users on the device are targeted. The script can also be distributed using the Intune scripts feature - but you still need to rely on Dynamic Groups for targeting.

A log is generated under the system temp folder.

<figure>

![](/images/2022/06/image-12.png)

<figcaption>

AppXRemoval Log File

</figcaption>

</figure>

Care should be taken when removing appx provisioned packages - it is not as easy to restore them as it is to remove them

## Summary

Remember, Appx Packages are installed in the User profile. Appx Provisioned Packages are installed in the Windows image and are used to provision appx packages, to the user profile, for each new user logging on to the device.

Restoring the appx provisioned packages, after removing them from Windows, is not an easy process so care should be taken when choosing which packages to remove.

I shared two scripted examples. The first had the appx provisioned packages, to remove, explicitly defined within the script body. The second referenced a .txt file, stored in GitHub, to remove the appx provisioned packages from Windows.

In environments, that require scripts to be signed, using a reference file for script variables is interesting. Obviously in our example we didn't have any sensitive information that shouldn't be seen by the public, so GitHub was fine to store the reference file.

If you want to start to get creative with reference files that include sensitive data we can look to store the file in Azure Blob storage and use a Shared Access Token or managed identity to access that file securely - and that gives me an idea for a future blog post.