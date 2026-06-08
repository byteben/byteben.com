---
title: "Create an Intune Configuration Profile to deploy the \"My Apps Secure Sign-in Experience\" Extension for Edge"
date: 2020-04-05
categories:
  - "Azure"
  - "Intune"
  - "Microsoft"
  - "Windows 10"
tags: ["extensions", "intune", "msedge", "myapps", "sso"]
categories: ["azure", "intune", "microsoft", "windows-10"]
---

### What is the "My Apps Secure Sign-in Experience" Extension for Edge

In order to leverage Single sign-on to your "Password Based" Azure AD applications, your Windows users will need to install a browser extension.

<!--more-->

The "My Apps Secure Sign-in Experience" Browser Extension will handle the authentication to applications using the credentials that are stored in a Password Vault in Azure. I have another post coming soon on how to enable SSO for password based applications \*

Your users will be prompted to download the extension when they select an application that is configured for "Password based” SSO. Alternatively, as an admin, you can deploy the extension to their computer - silently. Much better right?

\*The extension also allows you to access internal company URLs, from an internet device, for apps published using the Application Proxy.

<figure>

![](/images/2020/04/image.png)

<figcaption>

https://myapps.microsoft.com - User is prompted to install the extension when the access a password-based SSO enabled application

</figcaption>

</figure>

### Deploy the Extension with Intune

Before we can publish any extension to Edge using Intune, we must first get the Application ID and Update URL for the extension.

1 . Navigate to [https://microsoftedge.microsoft.com/addons/category/EdgeExtensionsEditorsPick](https://microsoftedge.microsoft.com/addons/category/EdgeExtensionsEditorsPick)

![](/images/2020/04/image-1-1024x731.png)

2 . Search for **My Apps Secure Sign-in Extension**

![](/images/2020/04/image-2.png)

3 . Grab the App ID from the URL - **gaaceiggkkiffbfdpmfapegoiohkiipl**

![](/images/2020/04/image-3-1024x524.png)

4 . Sign in at [https://devicemanagement.microsoft.com](https://devicemanagement.microsoft.com)

5 . Navigate to **Devices > Configuration Profiles**

![](/images/2020/04/image-4.png)

6 . Select **Create Profile**

![](/images/2020/04/image-5.png)

7 . Choose the **Platform** "Windows 10 and later" and the **Profile** "Administrative Templates"

![](/images/2020/04/image-6.png)

8 . Click **Create**

9 . Give the Configuration Profile a name e.g. **Edge Extensions - My Apps Secure Sing-in**

![](/images/2020/04/image-7.png)

10 . Click **Next**

11 . Select **Computer Configuration > Microsoft Edge > Extensions**

![](/images/2020/04/image-8.png)

12 . Select **Control which extensions are installed silently**

![](/images/2020/04/image-9-1024x514.png)

13 . Select **Enabled** and enter the Extension ID and Update URL using the following format and click **OK**

<**ExtensionID>;<UpdateURL**\>  
The Update URL for Edge Extensions is [https://edge.microsoft.com/extensionwebstorebase/v1/crx](https://edge.microsoft.com/extensionwebstorebase/v1/crx)

The ADMX value will be **gaaceiggkkiffbfdpmfapegoiohkiipl;https://edge.microsoft.com/extensionwebstorebase/v1/crx**

![](/images/2020/04/image-10.png)

14 . Click **Next**

15 . Click **Next**

16 . Click the **Assign to** drop down box and choose **All Devices \***

![](/images/2020/04/image-12.png)

**\*** You can be more selective and choose a group of devices to deploy the Configuration Profile to instead of **All Devices**

![](/images/2020/04/image-13.png)

17 . Click **Next**

18 . Review the profile and click **Create**

![](/images/2020/04/image-14.png)

19 . Review the deployment status of the new Configuration Profile

![](/images/2020/04/image-15.png)

20 . The devices will automatically install the extension. You can view if this was successful by viewing the extensions within Edge on the client device

![](/images/2020/04/image-16.png)

![](/images/2020/04/image-17.png)

### Summary

In this post, we observed how to add the "My Apps Secure Sign-in Experience" Extension for Edge from an Intune Configuration Profile.

In the next post, we will give an example of how we can leverage this browser extension to give your users an SSO experience accessing corporate social media accounts - without giving them the social media account credentials!