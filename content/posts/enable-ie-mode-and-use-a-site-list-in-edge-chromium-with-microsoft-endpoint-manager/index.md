---
title: "Enable IE Mode and use a Site List in Edge Chromium with Microsoft Endpoint Manager"
date: 2020-05-15
categories:
  - "ConfigMgr / MEMCM / SCCM"
  - "Intune"
  - "Microsoft"
  - "Windows 10"
tags: ["configmgr", "edge", "edge-chromium", "ie-mode", "intune", "mem", "memcm", "site-list"]
---

In this two part mini series we will look at enabling IE Mode in Edge Chromium using both Microsoft Intune and Microsoft Configuration Manager. I won't be deep diving how IE Mode works in this post (although I was tempted) but I have posted links to the Microsoft Docs throughout if you want to dig deeper.

<!--more-->

<figure>

![](/images/2020/03/iemode_intune_2-1024x537.jpg)

<figcaption>

Too much interest to focus on delivering this solution with only one half of Endpoint Manager

</figcaption>

</figure>

### Items Covered

1. [What is IE Mode?](#What_is_IE_Mode)
2. [What is a Site List?](#What_is_a_Site_List)
3. [Creating a Site List](#Creating_a_site_list)
4. [Prerequisites](#Prerequisites)
5. [Part 1: Enable IE Mode and use a Site List in Edge Chromium with Microsoft Intune](#Part1_Enable_IE_Mode_Intune)
6. Part 2: Enable IE Mode and use a Site List in Edge Chromium with Microsoft Configuration Manager

### What is IE Mode? [⏏](#NavMenu)

> IE mode on Microsoft Edge is a simplified experience that combines a modern rendering engine and compatibility with legacy sites that require Internet Explorer in a single browser. IE mode provides an integrated browsing experience in Microsoft Edge, using the integrated Chromium engine for modern sites and leveraging Internet Explorer 11 (IE11) for legacy sites that require the Trident MSHTML engine.
> 
> [https://docs.microsoft.com/en-us/deployedge/edge-ie-mode#what-is-ie-mode](https://docs.microsoft.com/en-us/deployedge/edge-ie-mode#what-is-ie-mode)

If we don't use IE Mode, and Edge Chromium is our default web browser, users could face issues when opening legacy websites that should open in IE. Microsoft have addressed this issue with "IE Mode". If Edge Chromium is their default browser, they can still open legacy websites in Chromium but we can force the website to use the IE engine to address compatibility issues.

We will cover this in more detail later but you can easily recognise if a website is being displayed in IE Mode by looking for the IE symbol in the address bar

<figure>

![](http://byteben.com/bb/images/2020/03/iemode_intune_1.jpg)

<figcaption>

IE Mode is enabled for this website

</figcaption>

</figure>

### What is a Site List? [⏏](#NavMenu)

In the context of "IE Mode", a Site List is a list of user defined websites whereby we can manipulate the rendering engine and compatibility mode within Edge Chromium. The Site List is created in the XML format and should be stored in one of the following locations:-

- (Recommended) HTTPS location\*: **https://azureblobstorageorsomething.com/IEMode\_Sites.xml** (we will be using a web server to store our Site List in this blog post)
- Local network file: **\\\\network\\shares\\sites.xml**
- Local file: **file:///c:/Users/<user>/Documents/sites.xml**

\* A copy of the Site List is cached on the client so will work even during periods of internet access being unavailable. **In case you haven't thought about it already, I highly recommend you post the XML on an Azure AD Secured Site that requires User/Device** **authentication (if there is sensitive data in the Site List). The Azure AD Application Proxy could be leveraged for example** [https://byteben.com/bb/azure-ad-application-proxy-accessing-your-internal-web-apps-from-the-internet/](https://byteben.com/bb/azure-ad-application-proxy-accessing-your-internal-web-apps-from-the-internet/)

The following modes are supported for websites defined in the Site List:-

- **IE11**: Opens the site in IE11, regardless of which browser is opened by the user.
- **MSEdge**: Opens the site in Microsoft Edge, regardless of which browser is opened by the user.
- **None**: Opens in whatever browser the user chooses.

We can configure the following compatibility modes for websites running in IE Mode

- **IE8Enterprise**: Loads the site in IE8 Enterprise Mode.
- **IE7Enterprise**: Loads the site in IE7 Enterprise Mode.
- **IE\[_x_\]**: Where \[x\] is the document mode number and the site loads in the specified document mode.
- **Default Mode**: Loads the site using the default compatibility mode for the page.

Read the following post for more information on modes and compatibility with IE Mode [https://docs.microsoft.com/en-us/internet-explorer/ie11-deploy-guide/add-single-sites-to-enterprise-mode-site-list-using-the-version-2-enterprise-mode-tool#adding-a-site-to-your-compatibility-list](https://docs.microsoft.com/en-us/internet-explorer/ie11-deploy-guide/add-single-sites-to-enterprise-mode-site-list-using-the-version-2-enterprise-mode-tool#adding-a-site-to-your-compatibility-list)

### Creating a Site List [⏏](#NavMenu)

There are two different ways to generate the Site List. Manually or using the "Enterprise Mode Site List Manager", version 2 (v.2) you can get that here [https://www.microsoft.com/en-us/download/details.aspx?id=49974](https://www.microsoft.com/en-us/download/details.aspx?id=49974)

One advantage of using the "Enterprise Mode Site List Manager" is it does a basic form of version control. More info on using the "Enterprise Mode Site List Manager" can be found here [https://docs.microsoft.com/en-us/internet-explorer/ie11-deploy-guide/use-the-enterprise-mode-site-list-manager](https://docs.microsoft.com/en-us/internet-explorer/ie11-deploy-guide/use-the-enterprise-mode-site-list-manager)

I won't go into detail on how to use the "Enterprise Mode Site List Manager", it is pretty straight forward.

The Site List is in an XML format. I used the "Enterprise Mode Site List Manager" executable above to create the initial XML formatting. I then found it straight forward to modify this XML manually to add additional websites. I maintain mine in Git so this is where my version control happens. Here is what the layout of the XML looks like:-

<figure>

![](/images/2020/03/iemode_intune_3-1024x901.jpg)

<figcaption>

Site List XML Layout

</figcaption>

</figure>

```
<site-list version="1">
  <created-by>
    <tool>EMIESiteListManager</tool>
    <version>10.0.14357.1004</version>
    <date-created>02/23/2020 14:28:42</date-created>
  </created-by>
  <site url="byteben.com">
    <compat-mode>Default</compat-mode>
    <open-in>IE11</open-in>
  </site>
  <site url="bbc.co.uk">
    <compat-mode>Default</compat-mode>
    <open-in>IE11</open-in>
  </site>
  <site url="starwars.com">
    <compat-mode>IE7Enterprise</compat-mode>
    <open-in>IE11</open-in>
  </site>
</site-list>
```

Another example can be found here [https://docs.microsoft.com/en-us/internet-explorer/ie11-deploy-guide/enterprise-mode-schema-version-2-guidance#enterprise-mode-v2-schema-example](https://docs.microsoft.com/en-us/internet-explorer/ie11-deploy-guide/enterprise-mode-schema-version-2-guidance#enterprise-mode-v2-schema-example)

For the benefit of this post, i uploaded a demo Site List to [https://byteben.com/bb/IEMode.xml](https://byteben.com/bb/IEMode.xml) We will cover the Edge Compat URL seen below later in this post, for now I wanted to show you that my Site List XML file is hosted on a web server - reachable by all my clients.

<figure>

![](/images/2020/03/iemode_intune_4-1024x556.jpg)

<figcaption>

Site List XML file uploaded to https://byteben.com/bb/IEMode.xml

</figcaption>

</figure>

### Prerequisites [⏏](#NavMenu)

There is an assumption that you are already using Edge Chromium if you are reading this post. If not, deploy it before you continue:-

- Manually: [https://www.microsoft.com/en-us/edge](https://www.microsoft.com/en-us/edge)
- Intune: [https://docs.microsoft.com/en-us/intune/apps/apps-windows-edge](https://docs.microsoft.com/en-us/intune/apps/apps-windows-edge)
- Configuration Manager: [https://docs.microsoft.com/en-us/deployedge/deploy-edge-with-configuration-manager](https://docs.microsoft.com/en-us/deployedge/deploy-edge-with-configuration-manager)

If you **are not** using Windows 10 1909, you will need to ensure that the correct update is installed on your clients before you continue. The full list of supported systems and required updates can be found at [https://docs.microsoft.com/en-us/deployedge/edge-ie-mode#prerequisites](https://docs.microsoft.com/en-us/deployedge/edge-ie-mode#prerequisites)

| Windows 10 | 1909 or later | No Update Required |
| --- | --- | --- |
| Windows 10 | 1903 | [KB4501375](https://support.microsoft.com/help/4501375/windows-10-update-kb4501375) or later |
| Windows Server | 1903 | [KB4501375](https://support.microsoft.com/help/4501375/windows-10-update-kb4501375) or later |
| Windows 10 | 1809 | [KB4501371](https://support.microsoft.com/help/4501371/windows-10-update-kb4501371) or later |
| Windows Server | 1809 | [KB4501371](https://support.microsoft.com/help/4501371/windows-10-update-kb4501371) or later |
| Windows Server | 2019 | [KB4501371](https://support.microsoft.com/help/4501371/windows-10-update-kb4501371) or later |
| Windows 10 | 1803 | [KB4512509](https://support.microsoft.com/help/4512509/windows-10-update-kb4512509) or later |
| Windows 10 | 1709 | [KB4512494](https://support.microsoft.com/help/4512494/windows-10-update-kb4512494) or later |

**Note:** Internet Explorer 11 must also be enabled in Windows Features for IE Mode to work

### Enable IE Mode and use a Site List in Edge Chromium with Microsoft Intune [⏏](#NavMenu)

It is recommended to host the Site List XML on a web server. Before you continue, ensure you have uploaded your Site List XML to a location reachable by all your Intune enabled clients.

1 . Create a new Configuration Profile for Edge at [https://devicemanagement.microsoft.com/#blade/Microsoft\_Intune\_DeviceSettings/DevicesMenu/configurationProfiles](https://devicemanagement.microsoft.com/#blade/Microsoft_Intune_DeviceSettings/DevicesMenu/configurationProfiles)

(1) **Name**: Microsoft Edge IE Mode  
( ) **Description**: Optional  
(2) **Platform**: Windows 10 and later  
(3) **Profile Type**: Administrative Templates  
(4) Click **Create**

<figure>

![](/images/2020/03/iemode_intune_5-1024x1018.jpg)

<figcaption>

Create a new Configuration Profile for Edge

</figcaption>

</figure>

2 . In **Settings** choose **Edge version 77 and Later** from the **Select a category type** drop down box

<figure>

![](/images/2020/03/iemode_intune_6-1024x537.jpg)

<figcaption>

In **Settings** choose **Edge version 77 and Later** from the **Select a category type** drop down box

</figcaption>

</figure>

3 . We need to configure two policies:-

  
3.1 . **Configure Internet Explorer integration (User)**

3.1.1 . Configure Internet Explorer integration **Enabled**  
3.1.2 . Configure Internet Explorer integration **Internet Explorer Mode**

<figure>

![](/images/2020/03/iemode_intune_7-950x1024.jpg)

<figcaption>

Configure Internet Explorer integration

</figcaption>

</figure>

3.2 . **Configure the Enterprise Mode Site List (User)**

3.2.1 . Configure the Enterprise Mode Site List **Enabled**  
3.2.2 . Configure the Enterprise Mode Site List **https://byteben.com/bb/IEMode.xml** << URL where your Site List is hosted

<figure>

![](/images/2020/03/iemode_intune_8-1024x643.jpg)

<figcaption>

Configure the Enterprise Mode Site List

</figcaption>

</figure>

Your configuration profile settings should look similar to this:-

<figure>

![](/images/2020/03/iemode_intune_9-1024x384.jpg)

<figcaption>

Two settings configure to Enable and Configure IE Mode

</figcaption>

</figure>

4 . We need to assign this configuration profile to our Users. Select **Assignments** and choose a User Group

<figure>

![](/images/2020/03/iemode_intune_10-1024x539.jpg)

<figcaption>

Assign the newly created configuration profile to a User Group

</figcaption>

</figure>

5 . On the **Assignments** blade, click **Save**

#### Verify IE Mode Configuration

Verify the Configuration Profile applied the policy in **HKEY\_CURRENT\_USER\\SOFTWARE\\Policies\\Microsoft\\Edge**

<figure>

![](/images/2020/03/iemode_intune_11-1024x287.jpg)

<figcaption>

Verify the User Policy was applied at **HKEY\_CURRENT\_USER\\SOFTWARE\\Policies\\Microsoft\\Edge**

</figcaption>

</figure>

Verify the Configuration applied to the Users device from the **Device Status** tab in the Configuration Profile we just created

<figure>

![](/images/2020/03/iemode_intune_12-1024x339.jpg)

<figcaption>

Verify the Configuration Profile applied to the assigned user on their device

</figcaption>

</figure>

Verify that IE Mode is now enabled and configured in Edge Chromium by navigating to [edge://compat/enterprise](edge://compat/enterprise)

<figure>

![](/images/2020/03/iemode_intune_13-1024x471.jpg)

<figcaption>

[edge://compat/enterprise](edge://compat/enterprise)

</figcaption>

</figure>

Verify the Websites configured in the Site List XML file are working in IE Mode

<figure>

![](/images/2020/03/iemode_intune_14-1024x520.jpg)

<figcaption>

IE Mode is working for the websites configured in the Site List

</figcaption>

</figure>

### Summary

As you can see, it is fairly straight forward to configure IE Mode for Edge Chromium using Microsoft Intune. In the next part of this mini series we will deliver the same policies using Configuration Manager.

Further Reading:- 
  
[https://docs.microsoft.com/en-us/internet-explorer/ie11-deploy-guide/enterprise-mode-overview-for-ie11](https://docs.microsoft.com/en-us/internet-explorer/ie11-deploy-guide/enterprise-mode-overview-for-ie11)  
[https://docs.microsoft.com/en-gb/DeployEdge/configure-edge-with-intune](https://docs.microsoft.com/en-gb/DeployEdge/configure-edge-with-intune)  
[https://docs.microsoft.com/en-us/deployedge/edge-ie-mode#what-is-ie-mode](https://docs.microsoft.com/en-us/deployedge/edge-ie-mode#what-is-ie-mode)