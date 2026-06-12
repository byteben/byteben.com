---
title: "AppSense Management Server Error after Installation - \"Could not load type 'System.ServiceModel. Activation.HttpModule' from assembly 'System.ServiceModel, Version=3.0.0.0, Culture=neutral, PublicKeyToken= b77a5c561934e089\""
date: 2013-06-18
tags: ["amc", "appsense", "appsense-environmentmanager", "appsense-management-server", "could-not-load-type-system-servicemodel-activation-httpmodule-from-assembly-system-servicemodel", "cultureneutral", "publickeytokenb77a5c561934e089", "version3-0-0-0"]
categories: ["appsense", "appsense-environmentmanager"]
---

We came across this problem after installing DesktopNow in a sandbox training environment. After installing the necessary prerequisites and subsequently the DesktopNow components we tapped in the AppSense Management Server URL to verify the AMC had successfully been installed.

<!--more-->

To our horror we got a nasty IIS error, as seen below:-

**Could not load type 'System.ServiceModel.Activation.HttpModule' from assembly 'System.ServiceModel, Version=3.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089**

[![AppSense Management Server URL Error](/images/2013/06/image-1024x723.jpg)](http://byteben.com/bb/images/2013/06/image.jpg)

We were like, "oh man...get some sugar and caffeine out, this looks painful".

This issue was caused because there were multiple versions of the .NET Framework on our server and IIS was installed after .NET Framework 4.0 or before the Service Model in Windows Communication Foundation was registered. This was brought to our attention from the following msdn article [http://msdn.microsoft.com/en-us/library/hh169179(v=nav.70).aspx](http://msdn.microsoft.com/en-us/library/hh169179\(v=nav.70\).aspx). We were given the sandbox environment so I don't know if it was the order in which server components were installed or something else that caused this error. Anyway, the good news is that it is fairly simple to fix, we just need to re-register the correct version of .Net, steps below:-

1\. At a command prompt, change the directory to C:\\Windows\\Microsoft.NET\\Framework64\\v4.0.30319 2. Type: aspnet\_regiis.exe -iru 3. Type: iisreset

Job done, after a few seconds we were able to see our Management Server URL with no issues.