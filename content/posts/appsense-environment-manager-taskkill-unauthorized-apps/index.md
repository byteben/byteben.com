---
title: "Using AppSense Environment Manager to Taskkill Unauthorized Apps..What??"
date: 2013-02-12
categories:
  - "AppSense"
  - "AppSense - Environment Manager - Scripts"
  - "AppSense Environment Manager"
  - "AppSense Environment Manager Configurations"
---

_Warning: This post may ruffle some feathers!_ I will start out by saying that AppSense have a great product called "Application Manager". It is designed to take on User Rights Management, Application Control and Software Compliance Monitoring, more info can be found at [http://www.appsense.com/products/desktop/desktopnow/application-manager/](http://www.appsense.com/products/desktop/desktopnow/application-manager/ "AppSense Application Manager")

That being said, there may be a scenario when you would like to use EM invoke Taskkill when it sees an unauthorized process being launched. Let me say again, I will always advocate Application Manager for this job but I also want to show you how flexible EM can be in your environment..look at it as broadening ones horizons.

<!--more-->

We all know how neat EM is at firing off policies against "process started" nodes. So in this example I am using Microsoft Access to illustrate how we can get EM to kill MS Access if the computer does not meet certain criteria. At this point I just want to clarify (if I haven't made it obvious by now) that Application Manager is designed to do this job so please don't heckle when you see me using EM - I am simply using this as an illustration to show how flexible EM can be.

Here is a sample config illustrating the node policy for process msaccess.exe

[![Using AppSense Environment Manager to Taskkill Unauthorized Apps](/images/2013/02/access.jpg "Using AppSense Environment Manager to Taskkill Unauthorized Apps")](http://byteben.com/bb/images/2013/02/access.jpg)

Ok, so when EM sees msaccess.exe launched it checks to see if the computer is part of the group "Microsoft Office Professional Plus 2010" (This is an example of an Active Directory Group). We assume in this example that Application Manager is not installed in this environment and the client has AD groups setup to monitor software distribution. We assume the client has no control on what software is installed by its customers on the endpoints either.

> IMHO no large environment should be in a position where they are unable to monitor software installations or allow their customers to install software that requires licencing - unless it is a managed process.

Ok, enough politics, lets just look at the programming - which is very basic. First we check the computers group membership, if it fails the membership query then we launch taskkill (located in %systemroot%\\system32) to kill any image called msaccess.exe (thats the "/IM msaccess.exe" part). The "/F" at the end of the taskkill command simply runs the command forcefully (takes no prisoners or excuses and just kills the process in question). Full taskkill command below:-

```
%SystemRoot%\System32\taskkill.exe /IM MSACCESS.exe /F
```

Next we display a msgbox to the user to let them know why their application is about to get nuked from memory, I have done this with a very simple vbscript..see below:-

```
msgbox "Sorry, this Computer is is not Licensed to use that Software. Please contact the IT Service Desk on 555 555 555 if you wish to purchase a Licence or believe this program has been blocked in error."
```

So that's it, a simple example of how to use a process trigger. More practical examples may be to modify reg entries on process launch or sync some folders etc..the world is your oyster in this respect. Hope it has been useful.

## Using AppSense Environment Manager to Taskkill Unauthorized Apps

### Using AppSense Environment Manager to Taskkill Unauthorized Apps