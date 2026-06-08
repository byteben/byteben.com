---
title: "AppSense MSI Cleanup"
date: 2012-09-26
categories:
  - "AppSense"
  - "AppSense - Environment Manager - Scripts"
  - "AppSense Environment Manager"
  - "AppSense Environment Manager Configurations"
---

Ok, so I have a little obsessive compulsion when it comes to cleaning up old config files that are no longer needed. I notice the msi files build up a fair amount in the "%ProgramFiles%\\AppSense\\Management Center\\Communications Agent\\download" directory. I wanted to delete any files that are older than 30 days ( I figured I would never have to roll back any further than 30 days..gamble I know.)

Here is how I done it with my fav Microsoft executable..Robocopy <!--more-->

1\. Using AppSense Environment Manager, Create a folder called "tmp" in "%ProgramFiles%\\AppSense\\Management Center\\Communications Agent\\download"

2\. Under this action, create a custom Execute Action set to "Run as System" with the following attributes:-

a) **Filename:** %SystemRoot%\\System32\\Robocopy.exe

b) **Working Directory:** %SystemRoot%\\System32

c) **Command Line:**

```
"%ProgramFile%\AppSense\Management Center\Communications Agent\download\." tmp /minage:30 /XJ /W:0 /R:0 /S /E /DCOPY:T /MOVE
```

d) Select "Do not execute children of this action until the process has exited"

e) Select "Do not create window (console based applications)

[![AppSense MSI Cleanup ](/images/2012/09/AppSenseMSICleanup-150x150.jpg "AppSense MSI Cleanup")](http://byteben.com/bb/images/2012/09/AppSenseMSICleanup.jpg)

3\. Now create an action (set to Run as System) to delete the tmp folder "%ProgramFiles%\\AppSense\\Management Center\\Communications Agent\\download\\tmp

The newly created action should look similar to the screenshot below:-

[![AppSense MSI Cleanup Action](/images/2012/09/oldappsensemsicleanup1-150x150.jpg "AppSense MSI Cleanup Action")](http://byteben.com/bb/images/2012/09/oldappsensemsicleanup1.jpg)

Voila, any MSI older than 30 days is nuked from orbit "Its the only way to be sure" - Ripley

You can replace the "minage" variable in robocopy if you want to increase/decrease the number of days to keep an MSI. I run this as a shutdown action. Happy MSI destroying.

## AppSense MSI Cleanup

### AppSense MSI Cleanup