---
title: "Migrating Desktop Settings from Policy into the AppSense EM Database"
date: 2012-10-16
categories:
  - "AppSense"
  - "AppSense Environment Manager"
  - "AppSense Environment Manager Configurations"
tags: ["appsense", "appsense-environmentmanager", "appsense-environmentmanager-configurations", "appsense-environmentmanager-scripts-2", "windows-7-pinned-lists"]
---

Ok, let the head scratching begin. Seriously, get your finger nails sharpened cause the head scratching is about to get good. Let me frame the story..

Some very nice people at AppSense helped us with our initial EM policy a good while ago now. Our policy has since had more makeovers than a channel 4 house mum but the original ground work was good. We were doing some clever things to get the User Pinned Start Menu and Task-bar items to follow the user. Basically hiving in/out some reg keys and doing some folder synchronization at login/logoff.<!--more-->We done a basic folder synchronization on the following folder (to the users folder on the server) at login/logout:

```
%APPDATA%\Microsoft\Internet Explorer\Quick Launch
```

Then we hived the following keys (to the users folder on the server) at login/logout:

```
HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced
```

```
HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\StartPage
```

```
HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\StartPage2
```

```
HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\MenuOrder\Start Menu2\Programs
```

```
HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Streams
```

```
HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\UserAssist
```

```
HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Taskband
```

Everything was working fine but we noticed AppSense had included a few more reg keys when they introduced StartMenu/Taskbar personalization in EM 8.3...quite a few more actually.

So this is where the story begins and end(for now). We are trying to work out how to seamlessly migrate to move our pinned items into "Desktop Settings" without the users losing all of their pinned items. In test we kinda get it to work and don't think we are too far off. We have ticked the options in Desktop Settings to get AppSense to now handle thepinned items and we are also still doing our own folder syncro/reg hive still. In theory everything should work because you are doing the same action in 2 different places.

The first phase of testing seems a success. We are still hiving and folder syncroing (is that a word?) once at user login and then we set a reg flag to say that is the last time we are doing hiving and folder syncroing the old way. We then set an action at logout to say if the reg flag has been set delete the old pinned items and reg hive files from the users share on the server. This seems to work well. By now the pinned items are being handled by "Desktop Settings" in EM.

If the testing proves a success Ill update my blog with an exact walk through/config shortly.

If, in the mean time, anyone has a better way to do this..let me know...seriously, let me know!!:)

## Migrating Desktop Settings from Policy into the AppSense EM Database

### Migrating Desktop Settings from Policy into the AppSense EM Database