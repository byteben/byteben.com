---
title: "Appsense Not Personalizing Internet Explorer Trusted Sites"
date: 2012-09-26
categories:
  - "AppSense"
  - "AppSense Environment Manager"
  - "AppSense Environment Manager Configurations"
tags: ["appsense", "appsense-environmentmanager", "appsense-environmentmanager-configurations", "internet-explorer-trusted-sites"]
categories: ["appsense", "appsense-environmentmanager", "appsense-environmentmanager-configurations"]
---

Well, today it was brought to my attention that we weren't personalizing Internet Explorer Trusted Sites..woops. But as we are still rolling out AppSense I forgave myself. We added the following registry key to our Application Group "Internet\_Explorer" under the Registry Tab - Includes (see image below)

<!--more-->

```
HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains
```

[![AppSense - Personalizing Internet Explorer Trusted Sites](/images/2012/09/trustedsites-150x150.jpg "AppSense - Personalizing Internet Explorer Trusted Sites")](http://byteben.com/bb/images/2012/09/trustedsites.jpg)

Voila :)

## Appsense Not Personalizing Internet Explorer Trusted Sites

### Appsense Not Personalizing Internet Explorer Trusted Sites