---
title: "Generate Office 365 PAC Files with PowerShell"
date: 2019-01-25
categories:
  - "Microsoft"
  - "Office 365"
  - "Scripts"
tags: ["office-365", "pac", "powershell", "proxies", "proxy-server"]
---

If you have a proxy server in your environment and are using (or thinking about using) Office 365 then you will hit some pain barriers. As awesome as Office 365 is, she just isn't a fan of proxies.

<!--more-->

We used to be left to our own initiative, creating complex proxy bypass rules and guessing which URLs we had to exclude. This process is compounded if you also maintain a strict CIDR range on your Firewall for Office 365 endpoints.

Introducing **Get-PacFile**

> This script will access updated information to create a PAC file to prioritize Microsoft 365 Urls for better access to the service. This script will allow you to create different types of files depending on how traffic needs to be prioritized.
> 
> Microsoft Gallery Comment

Head over to the Gallery to view the script [https://www.powershellgallery.com/packages/Get-PacFile/1.0.4](https://www.powershellgallery.com/packages/Get-PacFile/1.0.4)

Go ahead and install it by using the command:-

```
 Install-Script -Name Get-PacFile 
```

<figure>

![](/images/2019/01/o365_pac1.jpg)

<figcaption>

Install-Script

</figcaption>

</figure>

You will be prompted to also install the "NuGet Provider". Go ahead.

### **Parameters**

Below is a list of parameters you can pass to the script to customize the generated PAC.

**Type** - The type of the proxy PAC file that you want to generate. 

- **1** - Send Optimize endpoint traffic direct and everything else to the proxy server. 
- **2** \- Send Optimize and Allow endpoint traffic direct and everything else to the proxy server. This type can also be used to send all supported ExpressRoute for Office 365 traffic to ExpressRoute network segments and everything else to the proxy server. 

**ClientRequestID** - This is required and is a GUID passed to the web service that represents the client machine making the call. 

_b10c5ed1-bad1-445f-b386-b919946339a7_

**Instance** - The Office 365 service instance which defaults to Worldwide. Also passed to the web service. 

- _Worldwide_
- _Germany_
- _China_
- _USGovDoD_
- _USGovGCCHigh_

**Tenant Name** - Your Office 365 tenant name. Passed to the web service and used as a replaceable parameter in some Office 365 URLs.

**DefaultProxySettings** - Your Proxy Server and Port preceded with the word "PROXY"

_"PROXY 10.11.12.13:8080"_

**DirectProxySettings**  - The direct proxy settings for priority traffic. 

**ServiceAreas** - What Services do you want defined in the PAC

- **Exchange** - Exchange Online and Exchange Online Protection 
- **SharePoint** \- SharePoint Online and OneDrive for Business 
- **Skype** - Skype for Business and Microsoft Teams 
- **Common** - Office 365 Pro Plus, Office Online, Azure AD and other common network endpoints 

**LowerCase** - Flag this to include lowercase transformation into the PAC file for the host name matching.

### Examples

> _.EXAMPLE   
>   
> .\\Get-PacFile.ps1 -ClientRequestId b10c5ed1-bad1-445f-b386-b919946339a7 -DefaultProxySettings "PROXY 4.4.4.4:70" > type1.pac   
>   
> .EXAMPLE   
>   
> .\\Get-PacFile.ps1 -ClientRequestId b10c5ed1-bad1-445f-b386-b919946339a7 -Instance China -Type 2 -DefaultProxySettings "PROXY 4.4.4.4:70" > type2.pac   
>   
> .EXAMPLE   
>   
> .\\Get-PacFile.ps1 -ClientRequestId b10c5ed1-bad1-445f-b386-b919946339a7 -Instance WorldWide -Lowercase -TenantName tenantName -ServiceAreas Sharepoint,Skyp_e
> 
> Examples given in the script

Don't forget to export the PAC to a file using >file.txt

```
Get-PacFile.ps1 -type 2 -ClientRequestId b10c5ed1-bad1-445f-b386-b919946339a7 -Instance Worldwide -DefaultProxySettings "PROXY 10.11.12.13:8080" -LowerCase -TenantName byteben -ServiceAreas Sharepoint,Skype,Exchange,Common > D:\pac.pac
```

<figure>

![](/images/2019/01/o365_pac2.jpg)

<figcaption>

Example of PAC Generated

</figcaption>

</figure>

<figure>

![](/images/2019/01/o365_pac3.jpg)

<figcaption>

"Tenant" parameter passed and highlighted in the generated PAC file

</figcaption>

</figure>