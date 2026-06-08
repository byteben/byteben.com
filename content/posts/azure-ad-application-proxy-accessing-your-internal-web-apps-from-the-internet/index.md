---
title: "Azure AD Application Proxy - \"Accessing your internal Web Apps from the Internet\""
date: 2019-11-09
categories:
  - "Azure"
  - "Identity"
  - "Microsoft"
  - "Windows 10"
tags: ["aad", "aad-application-proxy", "azure", "azure-active-directory", "intranet", "proxy-connector"]
---

Welcome to this blog post on Azure Active Directory Application Proxy. This post comes off the back of an awesome day at the East of England Microsoft User Group #EEMUG. In this post we will take you through the fundamentals and the requirements of Azure AD Application Proxy and how to publish your internal Web Apps to Internet connected users.

<!--more-->

This post will focus on:-

1. What is Azure AD Application Proxy?
2. Components of Azure AD Application Proxy
3. How does Azure AD Application Proxy Work?
4. Application Proxy Connectors and Connector Groups
5. Prerequisites for Azure AD Application Proxy
6. Installing Azure AD Application Proxy
7. Creating Enterprise Apps for Azure AD Application Proxy

### 1 . What is Azure AD Application Proxy?

Azure Active Directory (AAD) Application Proxy is a feature of Azure Active Directory.  
It provides secure remote access to on-premises web applications such as:-

1. Web applications hosted behind a Remote Desktop Gateway
2. SharePoint
3. Web APIs that you want to expose to rich applications on different devices
4. Rich client apps that are integrated with the Active Directory Authentication Library (ADAL)

AAD Application Proxy is secure. You do not need to open incoming ports on your firewall for internet connected users to access your internal web apps. The application proxy connector (more on this later) only requires outbound ports 80 & 443 to the internet.

We would typically deploy the AAD Application Proxy Service when we have intranet sites that are not cloud ready.

### 2 . Components of Azure AD Application Proxy

The AAD Application Proxy consists of 3 main components:-

1. Azure Active Directory
2. Application Proxy Service - Feature of AAD
3. Application Proxy Connector - Installed on your intranet server(s)

[![](http://byteben.com/bb/images/2019/11/aad-appproxy_1-1-1024x485.png)](blob:https://byteben.com/b5b29f5c-55fe-487a-8315-3988e472d3ae)

### 3 . How does Azure AD Application Proxy Work?

The AAD Application Proxy can be used to pre-authenticate your users before they access web apps on your intranet. In my opinion, this has to be one of its biggest advantages. If we use AAD to pre-authenticate our users, we can leverage features like Conditional Access, MFA and other Identity Protection services.

**High Level flow of the Azure AD Application Proxy feature**

![](/images/2020/07/image-27.png)

1. The user access the published web app and is redirected to authenticate with Azure AD
2. If sign-in is successful, Azure AD gives the client a token
3. The client sends the token to the Application Proxy Connector Service\* where the UPN and, if required, the SPN is extracted
4. The request is sent to the Application Proxy Connector
5. If configured for SSO, the Application Proxy Connector performs additional authentication (KCD) on behalf of the user
6. The request is sent to the web app
7. The web app responds, via the Application Proxy Service, to the user

\* Remember only outbound ports are required from the Application Proxy Connector(s). The Application Proxy Connector periodically polls the Application Proxy Service for any incoming requests

### 4 . Application Proxy Connectors and Connector Groups

An Application Proxy Connector is downloaded and installed on a server that is preferably in the same network segment as the back-end web application servers.

[![](http://byteben.com/bb/images/2019/11/aad-appproxy_3-1.png)](/images/2019/11/aad-appproxy_3.png)

Microsoft recommends a minimum of two connectors to allow for high availability to your back-end web application. They can be installed manually or scripted with PowerShell (requires the use of offline tokens for initial service authentication). Certificates to authenticate with the Connector Service are created during the initial registration and are automatically renewed by the Connectors every couple of months.

There are two services installed with each Application Proxy Connector

1. Microsoft AAD Application Proxy Connector
2. Microsoft AAD Application Proxy Connector Updater

<figure>

[![](http://byteben.com/bb/images/2019/11/aad-appproxy_5-1.png)](blob:https://byteben.com/1612f286-c642-43f4-b52a-a326560a2a1c)

<figcaption>

Application Proxy Connector - Installed Services

</figcaption>

</figure>

The Connectors handle high availability during periods of high load or Connector unavailability.

Although not strictly necessary, solutions like Express Route should be considered to ensure Connectors can communicate quickly with the Application Proxy Service.

The table below offers an indication of how many Connectors are recommended depending on the expected number of transactions per second to your back-end web application

<figure>

[![](http://byteben.com/bb/images/2019/11/aad-appproxy_4-1.png)](/images/2019/11/aad-appproxy_4.png)

<figcaption>

Size the number of Connector to the expected number of Transactions per Second

</figcaption>

</figure>

**Connector Groups** enable you to assign specific connectors to serve specific applications. You can group a number of connectors together, and then assign each application to a Connector Group.

<figure>

[![](http://byteben.com/bb/images/2019/11/aad-appproxy_6-1.png)](blob:https://byteben.com/ccd6c543-650a-4871-86a5-7e858c1d8887)

<figcaption>

Application Proxy Connector Groups

</figcaption>

</figure>

Connector groups make it easier to manage large deployments. They also improve latency for tenants that have applications hosted in different regions, because you can create location-based connector groups to serve only local applications.

### 5 . Prerequisites for Azure AD Application Proxy

You guessed it...licenses :) Let's have a look at the pre-requisites to get up and running with the AAD Application Proxy Feature

- Users require an AAD Premium Licence (P1 or P2)
- Azure AD Tenant (Assumed)
- Application Proxy Connector machines must be enabled for TLS 1.2
- Connectors must be installed on Server 2012R2 or higher
- Connectors must be installed on a Domain Joined machine if you want single sign-on (SSO) to applications that use Integrated Windows Authentication (IWA) \*
- It is recommended to configure a minimum of two Proxy Connectors
- The "Application Administrator" or "Global Administrator" Role is required to install the connector

\* Connector machines must be Domain Joined in order to perform Kerberos Constrained Delegation (KCD), on behalf of users, to the back-end web apps.

### 6 . Installing Azure AD Application Proxy

<figure>

https://youtu.be/VewigMyXPVU

<figcaption>

Installing the AAD Application Proxy Connector

</figcaption>

</figure>

### 7 . Creating Enterprise Apps for Azure AD Application Proxy

<figure>

https://www.youtube.com/watch?v=s7aPDrYSfd4&feature=youtu.be

<figcaption>

Creating Enterprise Apps for Azure AD Application Proxy

</figcaption>

</figure>

### Summary

In this blog post we looked at the Azure Active Directory Application Proxy. This is a really neat feature of Azure AD to allow your internet based users to access internal web apps that are not ready to move to the cloud.

Having Azure AD being able to pre-authenticate access to these internal web apps is the big win here. This coupled with the Proxy Connector computer being able to perform Kerberos Constrained Delegation for a SSO experience on IWA web apps adds the icing on the cake.

If you would like me to expand on any area, please comment below. If you prefer step-by-step instructions instead of YouTube lab videos I would love to hear this feedback too.

Thanks for reading!