---
title: "AppSense Environment Manager Custom Action Script Exit Codes"
date: 2013-02-26
categories:
  - "AppSense"
  - "AppSense - Environment Manager - Scripts"
  - "AppSense Environment Manager"
  - "AppSense Environment Manager Configurations"
  - "Scripts"
tags: ["appsense", "appsense-environmentmanager", "appsense-environmentmanager-configurations", "appsense-environmentmanager-scripts-2", "jscript", "powershell", "vbscrip", "wscript-quit"]
---

Hands up, fair cop. In a recent blog post on [scripting Internet Explorer Favorites](http://byteben.com/bb/adding-corporate-favorite-items-users-profile-appsense-environment-manager/) I forgot to mention using script exit codes when I dealt with the custom actions. Any custom script you include in your configuration is always interpreted as completing successfully by the agent on exit unless you specify otherwise in your code. <!--more-->As we were just firing off some pretty basic scripting and not needing to know the return code of the script to leverage another trigger I didn't use it. I guess the more stricter of coder would always include error control so I bow submissively to anyone who suggests I should have used it too.

In the blog post "[scripting Internet Explorer Favorites](http://byteben.com/bb/adding-corporate-favorite-items-users-profile-appsense-environment-manager/)" we used some vbscript. The correct success/fail exit code to use in this example would be:-

```
WScript.Quit [value]
```

Other scripting languages would be:-

JScript:-

```
WScript.Quit([value])
```

PowerShell:-

```
exit ([value])
```

\[value\] should be replaced with the exit code appropriate for the scripting language used. 0 is used for success and 1 is used for failure.

For example:

```
WScript.Quit 1
```

```
WScript.Quit(1)
```

```
exit (1)
```

## AppSense Environment Manager Custom Action Script Exit Codes

## AppSense Environment Manager Custom Action Script Exit Codes