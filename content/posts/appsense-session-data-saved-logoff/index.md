---
title: "AppSense Environment Manager Session Data Not Saved at Logoff - EmExit.bat"
date: 2013-06-11
categories:
  - "AppSense"
  - "AppSense - Environment Manager - Scripts"
  - "AppSense Environment Manager"
  - "AppSense Environment Manager Configurations"
  - "Scripts"
---

No session data or Desktop Settings saved at Logoff? We came across this particular problem on about 30 of our Windows 7 PCs. They were all born from the same Gold image as the other working 300 or so desktops (we are about half way through our Windows 7 migration) but these few PCs all presented the same issue. We were seeing no Session Data, Desktop Settings or Logoff actions completing at User Logoff.<!--more-->

Basic settings like default printers not persisting drew our attention to this fault and consequently we were led down a very, very dark alley of pain that would have made Smeagle wince.

Ok, so we started from the top - what process calls Session Data and Desktop Settings to be synced at logoff? Why, EmExit.bat of course. If you run an rsop.msc on any endpoint with an AppSense Environment Manager Agent installed you will see emexit.bat listed as  a user logoff script (see below)

[![AppSense Environment Manager Session Data Not Saved at Logoff](/images/2013/06/AppSense-Environment-Manager-Session-Data-Not-Saved-at-Logoff-2.jpg)](http://byteben.com/bb/images/2013/06/AppSense-Environment-Manager-Session-Data-Not-Saved-at-Logoff-2.jpg)

 

You will also see a similar script (actually the same one) under "Computer Configuration". The same EmExit.bat script is called at both Logoff and Shutdown. The agent refers to the parameter run against the script to distinguish between Logoff and Shutdown actions in your configuration. -l for logoff and -s for shutdown.

Stay with me, here was the first head scratching moment. On our affected endpoints, there were no "User Configuration" Logoff scripts. Excuse me? No, none. We had already stripped the agent off and tried a re-install but whatever re-installation method we tried we still had no user logoff script. Even creating a separate logoff script outside of the AppSense environment wasn't appearing....hmmm....something Microsoft faulty?

With a little help from the Microsoft Professional Services team, we narrowed it down to a potential issue with GPT.INI. The GPT.INI file at %SYSTEMROOT%\\System32\\GroupPolicy\\GPT.ini contains information indicating:-

- Which client-side extensions (CSE's) of the Group Policy Object Editor contain User or Computer data in the GPO.
- Whether the User or Computer portion is disabled.
- Version number of the Group Policy Object Editor extension that created the Group Policy object.

So what does the Microsoft GPT.INI have to do with EmExit.bat not loading? For those of you not in the know, the EM Core Service checks the GPT.INI on start-up to ensure the CSE for script processing is present. If it isn't, it adds it to the end of the list of CSE's.

It seems that in doing so, the EM Core Service was corrupting the GPT.INI file of our 30 affected endpoints. Below is a normal looking GPT.INI

[![AppSense Environment Manager Session Data Not Saved at Logoff](/images/2013/06/AppSense-Environment-Manager-Session-Data-Not-Saved-at-Logoff-3.jpg)](http://byteben.com/bb/images/2013/06/AppSense-Environment-Manager-Session-Data-Not-Saved-at-Logoff-3.jpg)Compare that image with the one below on one of our faulty endpoints[![AppSense Environment Manager Session Data Not Saved at Logoff](/images/2013/06/AppSense-Environment-Manager-Session-Data-Not-Saved-at-Logoff-4.jpg)](http://byteben.com/bb/images/2013/06/AppSense-Environment-Manager-Session-Data-Not-Saved-at-Logoff-4.jpg)So we had different combinations of square and open/close brace (squiggly) brackets. The EM Core Service was corrupting our GPT.INI file and preventing it from processing CSEs correctly.

We manually corrected the syntax in each of our GPT.INI files and everything started working again. I strongly suggest not just blanket copying the GPT.INI file among your end points - the version number will be unique to each client depending on what GPO Editor extension created that GPO.

**UPDATE**

We got this far and after we handed this info to AppSense we were told this IS a known bug... arghhhhhh - "Why didn't you tell us when we originally logged the call"? No bother, we din't get upset, it was actually an interesting lesson to understand the EmExit.bat process. So, log into [MyAppSense](https://www.myappsense.com/Knowledgebase/TN-150694.aspx) and lookup TN150694. This bug is fixed in later releases of EM, we were running 8.3.157 at the time.

**NOTE**

We have a nice VBScript that we included in our EM config. The script (at User Logon) would check for the existence of the "HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Group Policy\\Scripts\\Logoff" key. If that key did not exist it meant EmExit.bat wouldn't run so we set a conditional trigger to fire an email to the service desk - worked a treat! Ok, Ok, Ok already vb script below:-

```
Set oNetwork = CreateObject("WScript.Network")
sUserName = oNetwork.UserName
sComputerName = oNetwork.ComputerName
SMTPServer = "192.168.0.1"
Recipient = "servicedesk@domain.com"
From = "appsense@domain.com"
Subject = "AppSense EmExit.bat RegEntry Missing for '" & sUserName & "' On Computer '" & sComputername & "'"
GenericSendmail SMTPserver, From, Recipient, Subject, Message
Sub GenericSendmail (SMTPserver, From, Recipient, Subject, Message)
set msg = WScript.CreateObject("CDO.Message")
msg.From = From
msg.To = Recipient
msg.Subject = Subject
msg.TextBody = Message
msg.Configuration.Fields ("http://schemas.microsoft.com/cdo/configuration/smtpserver") = SMTPServer
msg.Configuration.Fields("http://schemas.microsoft.com/cdo/configuration/sendusing") = 2
msg.Configuration.Fields.Update
msg.Send
End Sub
```

This script would need to be run in the user context. That is it I think, feel free to comment or ask questions :)

## AppSense Environment Manager Session Data Not Saved at Logoff

### AppSense Environment Manager Session Data Not Saved at Logoff