---
title: "Migrating Outlook 2003 NK2 File into Outlook 2010 with AppSense"
date: 2012-10-30
categories:
  - "AppSense"
  - "AppSense Environment Manager"
  - "AppSense Environment Manager Configurations"
tags: ["appsense", "appsense-environmentmanager", "appsense-environmentmanager-configurations", "nk2-file-import", "outlook-2010", "outlook-2010-nk2"]
categories: ["appsense", "appsense-environmentmanager", "appsense-environmentmanager-configurations"]
---

AppSense Environment Manager can help you migrate an XP User to Windows 7 very easily and seemlessly. For various reasons, partly due to how our desktop estate was configured horribly historically,  we decided to export our Windows XP users "Vital" settings using a simple script. We have to visit each user anyway to give them new hardware and because we are very customer centric we give them about half an hour overview on their new Windows 7 PC...because we care :)

<!--more-->

So, we find ourselves in this situation. "John Doe" is about to be relieved of his/her (can a girl be called John?..whatever) 6 year old Windows XP desktop PC and presented with his/her shiny new Dell Optiplex 790 with Windows 7 installed.

_Outlook 2010 doesn't use the NK2 file anymore, it stores the nickname cache in a hidden message in the users mailbox store. Yipeee..no more corrupt flat file NK2 files. The nickname cache can now be viewed from the "Suggested Contacts" address book in Outlook 2010._

The last thing we do before John Doe logs off their old XP PC is run our Export Script. Part of this script locates the users NK2 file (If you dont know what an NK2 file is then you probably shouldn't be reading this post) and exports it to a file share which will be accessible from his new Windows 7 PC.

The NK2 file will be called \*something\*.NK2. \*something\* = what ever their old outlook profile was called. Normally (well in our experience) it is called Outlook.NK2.So...Our script exports \*.NK2 files from the users profile to a network share. We then look at the most recently modified NK2 file and ensure it is called Outlook.NK2. There are lots of ways to achieve this export and file rename but I have not included that in this Post. _If enough people shout I will think about it._

 

Ok, so we now have our Outlook.NK2 file sitting on a network share that will be accessible to that user from their new Windows 7 PC..lets get AppSense involved.

We have a custom executable in our "Startup Group" called "CompanyPersonalization.exe". We then create a node under "Process Started" in EM for process "CompanyPersonalization.exe" to hook our actions on. We personally found that hooking all our nodes under user logon can hold up logon time so we do some of our funky stuff from this exe in the Windows Startup Folder. It gives the user the perception that their desktop is loading faster...I said perception! :)

Here is a look at our config, ill explain it below:-

[![migrating-outlook-2003-nk2-file-outlook-2010-appsense](/images/2012/10/migrating-outlook-2003-nk2-file-outlook-2010-appsense.jpg "migrating-outlook-2003-nk2-file-outlook-2010-appsense")](http://byteben.com/bb/images/2012/10/migrating-outlook-2003-nk2-file-outlook-2010-appsense.jpg)

1\. First we check if the user logging on is a Windows 7 user. We use this condition alot.

2\. Next we check to see if they have Outlook installed on their PC.

3\. Next we check for a registry flag. We only want to run this action once so after the action completes successfully we set a custom reg flag.

4\. We then check to see if Oulook.NK2 exists on the file share we spoke about earlier.

5\. Next we copy the NK2 file to "%APPDATA%\\Microsoft\\Outlook\\Outlook.NK2". Dont worry, we are not trying to inject the NK2 file into the AppSense Database at this point, we are simply copying it to the users non personalized %appdata% folder. Appsense gnus will understand.

6\. Next we start Oulook with the /NK2 switch. This promtps outlook to look in the above location and import the Outlook.NK2 file into the users exchange mailbox.

7\. Finally we set a flag so at next logon this process wont be repeated.

So, fairly basic config. We are simply telling AppSense to copy the outlook.nk2 file to the users %appdata% folder and then run Outlook.exe /importnk2 the first time the user logs in. No more explanation needed I feel. Hope it helps.

A good MS article on how to migrate NK2 files can be found here for a more detailed outline of the process. [http://support.microsoft.com/kb/980542](http://support.microsoft.com/kb/980542)

## Migrating Outlook 2003 NK2 File into Outlook 2010 with AppSense

### Migrating Outlook 2003 NK2 File into Outlook 2010 with AppSense