---
title: "How to Personalize Microsoft Office 2010 with AppSense"
date: 2013-06-19
tags: ["csidl_appdatamicrosoftexcel", "csidl_appdatamicrosoftword", "appsense", "appsense-application-group", "appsense-environmentmanager", "appsense-environmentmanager-configurations", "autorecover", "office-2010", "office-2010-personalization"]
categories: ["appsense", "appsense-environmentmanager", "appsense-environmentmanager-configurations"]
---

Microsoft Office 2010 can be personalised with AppSense Environment Manager. AppSense have a "Best Practice" guide which is available from www.myappsense.com. The guys did a good job with it and we used it as a baseline. Most of the information here is reflected in the guide but, and please don't drag me over the coals, we do some of the %appdata% folder includes\\excludes differently, and I'll explain why. <!--more-->

I will assume you are au fait with creating Application Definitions and Application Groups and you already know your way around EM. So let us start with the basics.

Start off by creating some new User Applications for each of the following executables in the Office suite. Then add these executables to a new, appropriately named, Application Group e.g. "Microsoft Office 2010"

NOTE: When adding these executable definitions, the regular expression for "Version Reg Ex" should be **^14.\*** if we are personalizing Office 2010. Adjust this value as necessary for other versions of Office.

Excel.exe Infopath.exe Msaccess.exe Mspub.exe Mstordb.exe Mstore.exe OfficeImport.exe Ois.exe Outlook.exe Powerpnt.exe Winword.exe

Ok, so we should have a new application group called something like "Microsoft Office 2010" with the above exe's assigned to this group. Now lets add some registryand file includes and excludes for our Application Group.

**Registry Includes:-**

```
HKCU\Software\Microsoft\Office
HKCU\Software\Microsoft\Shared
HKCU\Software\Microsoft\Shared Tools
```

**Registry Excludes:-** _(thanks Landon for the revised info)_

```
HKCU\Software
HKCU\Software\Microsoft\Office\14.0\Access\Resiliency\DocumentRecovery
HKCU\Software\Microsoft\Office\14.0\Common\Research
HKCU\Software\Microsoft\Office\14.0\Excel\Resiliency\DocumentRecovery
HKCU\Software\Microsoft\Office\14.0\Outlook\Resiliency\DocumentRecovery
HKCU\Software\Microsoft\Office\14.0\PowerPoint\Resiliency\DocumentRecovery
HKCU\Software\Microsoft\Office\14.0\Word\Resiliency\DocumentRecovery
```

**File Includes:-**

\*The items in red will need some explaining why I do this differently to best practice\*

```
{CSIDL_APPDATA}\Microsoft\Excel\XLSTART
{CSIDL_APPDATA}\Microsoft\Graph
{CSIDL_APPDATA}\Microsoft\Infopath
{CSIDL_APPDATA}\Microsoft\Office
{CSIDL_APPDATA}\Microsoft\OIS
{CSIDL_APPDATA}\Microsoft\Outlook
{CSIDL_APPDATA}\Microsoft\PowerPoint
{CSIDL_APPDATA}\Microsoft\Proof
{CSIDL_APPDATA}\Microsoft\Protect
{CSIDL_APPDATA}\Microsoft\Publisher
{CSIDL_APPDATA}\Microsoft\Signatures
{CSIDL_APPDATA}\Microsoft\Stationary
{CSIDL_APPDATA}\Microsoft\Templates
{CSIDL_APPDATA}\Microsoft\UProof
{CSIDL_APPDATA}\Microsoft\Word\STARTUP
{CSIDL_LOCAL_APPDATA}\Microsoft\Office
```

**File Excludes:-** _(thanks Landon for the revised info)_

```
{CSIDL_APPDATA}
{CSIDL_COMMON_APPDATA}
{CSIDL_PROFILE}
{CSIDL_APPDATA}\Microsoft\Excel
{CSIDL_APPDATA}\Microsoft\Office\14.0\OfficeFileCache
{CSIDL_APPDATA}\Microsoft\Templates\LiveContent
{CSIDL_APPDATA}\Microsoft\Word
{CSIDL_LOCAL_APPDATA}\Microsoft\Office\14.0
```

These includes and excludes will pretty much get you going. They are not exclusive and I have seen some other good keys\\folders defined by other bloggers. We do have other excludes but they are unique to our environment and reflect how tightly we personalize specific data for Microsoft Office.

Ok, let me address the items in red...

Office 2010 applications, by default, will save any AutoRecovered documents, after an application crash, to the users %appdata% folder. These are:-

```
{CSIDL_APPDATA}\Microsoft\Word
{CSIDL_APPDATA}\Microsoft\Excel
{CSIDL_APPDATA}\Microsoft\Powerpoint
{CSIDL_APPDATA}\Microsoft\Publisher
```

When the app crashes and saves an autorecovered version of the users file, this file will be copied up to your personalization server when you next exit the application. I have seen some AppSense profiles grow horrendously if we do not exclude these file locations.\*

Unfortunately, we cannot just simply exclude these locations from personalization for the application group without having an effect on other office components. For example, {CSIDL\_APPDATA}\\Microsoft\\Word has a subfolder called STARTUP and {CSIDL\_APPDATA}\\Microsoft\\Excel has a subfolder called XLSTART - both of these folders are the default file locations for Macro enabled documents used on app start-up. Adobe also likes to put PDF toolbar items into these folders. Also, things like the auto list library are stored in {CSIDL\_APPDATA}\\Microsoft\\Word folder so consideration needs to be made on how to get these items in and out of personalization if, like us, you decide to exclude it.

\*Also, consider playing with Group Policy to change the Auto Recover location if things start getting sticky.

I live in a goldfish bowl so this applies well in our environment. Test, test, test to see how it will affect your users and I definitely recommend, if you don’t already, do some personalization analysis using the data collection option on your test personalization group to see exactly what is being saved in those locations and reg keys.

Again, this config reflects how we do things in our organisation and may not be applicable, in its entirety, to yours. Please comment if you have some other useful tips for Office 2010 personalization. The AppSense user community is growing strong and I am a firm believer in sharing knowledge to eek the best out of the product and maximize its use in our organisations.

## How to Personalize Microsoft Office 2010 with AppSense

### How to Personalize Microsoft Office 2010 with AppSense