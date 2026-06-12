---
title: "Adding Corporate Favorite Items to a Users Profile using AppSense Environment Manager"
date: 2013-02-25
tags: ["appsense", "appsense-environmentmanager", "appsense-environmentmanager-configurations", "appsense-environmentmanager-scripts-2", "scripts-2", "user-favorites", "vb-script", "vb-script-favorites"]
categories: ["appsense", "appsense-environmentmanager-scripts", "appsense-environmentmanager", "appsense-environmentmanager-configurations", "scripts"]
---

Well this is certainly something we wanted to do in our environment. Based on different group memberships and user requirements for different web apps we wanted to post links into the users favorites folders in Internet Explorer. Historically, users managed their own app shortcuts in the Favorites folder but this led to inconsistencies especially when a url was updated server side. We decided to publish a folder called "!Corporate" in the users favorites folder. This folder (if sorted alphabetically) would appear at the top of the users favorites and we would leverage the ability to run vb script from an Environment Manager trigger. We could then add/delete/modify urls and keep a consistent-corporate approach to managing these items. <!--more-->Below is how we achieved this:-

1\. Our first step was to create a new node on the User Logon tree in Environment Manager.

2\. Next we created a folder in the users Favorites folder called "!Corporate". Note: In our environment we use an environment variable called %UVFS% to address the users profile which is a redirected folder on a server share (Thanks [@UVArchitect](https://twitter.com/UVArchitect) for this recommendation back in the day).

[![Adding Corporate Favorite Items to a Users Profile using AppSense Environment Manager](/images/2013/02/Adding-Corporate-Favorite-Items-to-a-Users-Profile-using-AppSense-Environment-Manager-1.jpg)](http://byteben.com/bb/images/2013/02/Adding-Corporate-Favorite-Items-to-a-Users-Profile-using-AppSense-Environment-Manager-1.jpg)

3\. We then create a child "Custom Action" node and change the type to "vbscript". Note: It is recommended to set a timeout value when running this script so the user logon process doesn't get held up by any poor scripting (example of poor scripting below:) ) The default value is 0 which means it wont timeout, the max value is 60 (seconds). From the manual: _"Actions with invalid scripts return a fail and any child actions do not run. Prior to Environment Manager 8.1 custom actions passed whether the script was valid or not"._

[![Adding Corporate Favorite Items to a Users Profile using AppSense Environment Manager](/images/2013/02/Adding-Corporate-Favorite-Items-to-a-Users-Profile-using-AppSense-Environment-Manager-2.jpg)](http://byteben.com/bb/images/2013/02/Adding-Corporate-Favorite-Items-to-a-Users-Profile-using-AppSense-Environment-Manager-2.jpg)

4\. Next is the vb script itself. It is quite basic really. We set some env objects and....bah, you'll see it below:-

```
Set WshShell = CreateObject("WScript.Shell")
Set objEnv = WshShell.Environment("Process")
Set fso = CreateObject("Scripting.FileSystemObject")
strDesktopPath = objEnv("UVFS") & "\Favorites\!Corporate\">
Set objShortcutUrl = WshShell.CreateShortcut(strDesktopPath & "\URL with Space.lnk")
objShortcutUrl.TargetPath = "http://myserver:8080/Software/login.jsp"
objShortcutUrl.Save
Set objShortcutUrl = Nothing
Set objShortcutUrl = WshShell.CreateShortcut(strDesktopPath & "\Kneecap.lnk")
objShortcutUrl.TargetPath = "http://myserver2/Pages/default.aspx"
objShortcutUrl.Save
Set objShortcutUrl = Nothing
```

NOTE: It is very important to observe the placement of the back slashes in this script :)

We then basically repeat the " Set objShortcutUrl" line for other required shortcuts. The above example creates 2 URL.lnk's in the users Favorite folder at logon.

I argued with myself on whether the script should have conditional (if url does not exist) but I would also have to do a string comparison to ensure not only does the url.lnk exist but does the target match. The log files do not suggest that this node or way of scripting takes particularly long so I kept it simple.

Below is an example I use to delete a url from the user's favorite folder when it is no longer needed. I include it in the same node so I will not include setting the env again:-

```
Set strFiletoDelete = WshShell.CreateShortcut(strDesktopPath & "\Kneecap.lnk")
If (fso.FileExists(strFiletoDelete)) Then
fso.DeleteFile strFiletoDelete
Set strFiletoDelete = Nothing
End If
```

That's it really, no need to over complicate it.

 

## Adding Corporate Favorite Items to a Users Profile using AppSense Environment Manager

### Adding Corporate Favorite Items to a Users Profile using AppSense Environment Manager