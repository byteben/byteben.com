---
title: "Windows 10 - Hybrid Azure Active Directory Join for Federated Domains"
date: 2019-04-14
tags: ["adfs", "azure-ad-hybrid-join", "claims", "federation", "scp", "windows-10"]
categories: ["azure", "configmgr-memcm-sccm", "identity", "microsoft"]
---

### What is ADFS?

Active Directory Federation Services (ADFS) provides a secure mechanism to authenticate users, accessing applications (often in the cloud), using Active Directory credentials when Windows Integrated Authentication (WIA) is not possible.  

<!--more-->
  
Not so long ago ADFS was considered the go-to option when needing to authenticate Domain users accessing Office 365 services. With the introduction of Azure Authentication technologies ADFS struggles to sell itself with newer adoptions of Office 365. That being said, there are still specific use case for deploying ADFS and it certainly isn't going anywhere soon - Microsoft added some new feature to the ADFS Role in Server 2019:- 
  
[https://docs.microsoft.com/en-us/windows-server/identity/ad-fs/overview/whats-new-active-directory-federation-services-windows-server](https://docs.microsoft.com/en-us/windows-server/identity/ad-fs/overview/whats-new-active-directory-federation-services-windows-server)  
  
Some organisations may be starting their Office 365 journey with an established ADFS infrastructure. That's cool. Microsoft recognizes that some of us use ADFS and fully support this option when there is a requirement to register Domain Joined devices in Azure.

### Why Enable Hybrid Azure Active Directory Join?

One of the most understated features of Azure Active Directory is Conditional Access. I only want my users accessing their data if they meet a certain criteria. e.g. They are on a trusted corporate device, using Multi Factor Authentication (MFA) on a personal device and/or using an approved client app. More info on Conditional Access here:- 
  
[https://docs.microsoft.com/en-us/azure/active-directory/conditional-access/overview](https://docs.microsoft.com/en-us/azure/active-directory/conditional-access/overview)  
  
It would be a tall order to expect my users to use MFA every time they access an Office 365 service from their work computer so I might want to relax some of my Conditional Access policies if the connection is coming from a Domain Joined device. There is an expectation that we already have a good deal of control and security on Domain Joined devices..right?

### What does Hybrid Join actually do?

For Conditional Access to evaluate that the connection to Office 365 is coming from a Domain Joined device, we have to register these devices in Azure Active Directory - effectively allowing a trust to be formed in Azure Active Directory with the Domain Joined device. Once the Domain Joined device is "Registered" in Azure Active Directory, we can leverage Conditional Access policies.

<figure>

![](http://byteben.com/bb/images/2019/04/hybrid_0-1024x154.jpg)

<figcaption>

Hybrid Azure AD Joined Devices

</figcaption>

</figure>

### Azure Active Directory Connect

Starting with Azure AD (Active Directory) Connect 1.1.819.0 Microsoft made it really easy to instigate Azure Device Registration for those of us using ADFS. The wizard automatically updates the Service Connection Point (SCP) in our on-premises Active Directory and also creates the required ADFS Claims Rules.

Pre-Requisites for configuring Hybrid Join for a Federated Domain using Azure AD Connect:-

- Windows Server 2012 R2 with AD FS
- [Azure AD Connect](https://www.microsoft.com/download/details.aspx?id=47594) version 1.1.819.0 or higher.
- Domain and Forest Functional Level 2008R2 or higher (On lower versions, the user may not get a Primary Refresh Token during Windows logon due to LSA issues)
- Windows 10 devices 1607 or higher

Detailed pre-requisite information can be found at:- 
  
[https://docs.microsoft.com/en-us/azure/active-directory/devices/hybrid-azuread-join-plan](https://docs.microsoft.com/en-us/azure/active-directory/devices/hybrid-azuread-join-plan)

If you love a challenge, or are unable to use Azure AD Connect to configure the Hybrid, you can manually setup the environment, SCP and issuance of claims. More info can be found at:- 
  
[https://docs.microsoft.com/en-us/azure/active-directory/devices/hybrid-azuread-join-manual](https://docs.microsoft.com/en-us/azure/active-directory/devices/hybrid-azuread-join-manual)

### Client Considerations

Once you have completed the AADConnect Wizard, steps shown later, **ALL** Domain Joined, Windows 10 clients, will automatically hybrid join Azure AD at device startup or user login. You may want to limit which devices get hybrid Joined during your POC or initial roll-out phase.  
  
You can control this behavior by using either a GPO or SCCM Client Setting.

#### Group Policy

The following GPO allows you to control Device Registration: **Register domain-joined computers as devices**.

1. Open **Group Policy Management**.
2. Create a new or edit an existing policy for Device Registration
3. Go to **Computer Configuration** - **Policies** - **Administrative Templates** - **Windows Components** - **Device Registration**.
4. Right-click **Register domain-joined computers as devices**, and then select **Edit \***
5. Select one of the following settings, and then select **Apply**:
    - **Disabled**: To prevent automatic device registration.
    - **Enabled**: To enable automatic device registration.
6. Select **OK**.

<figure>

[![](/images/2019/04/hybrid_3.jpg)](/images/2019/04/hybrid_3.jpg)

<figcaption>

Group Policy setting for Windows 10 Device Registration

</figcaption>

</figure>

\*This Group Policy template has been renamed from earlier versions of the Group Policy Management console. If you're using an earlier version of the console, go to **Computer Configuration** > **Policies** > **Administrative Templates** > **Windows Components** > **Device Registration** > **Register domain joined computer as device**.

#### SCCM Client Setting

1. Open **Configuration Manager**, select **Administration**, and then go to **Client Settings**.
2. Open the properties for **Default Client Settings** and select **Cloud Services**.
3. Under **Device Settings**, select one of the following settings for **Automatically register new Windows 10 domain joined devices with Azure Active Directory**:
    - **No**: To prevent automatic device registration.
    - **Yes**: To enable automatic device registration.
4. Select **OK**.

<figure>

[![](/images/2019/04/hybrid_2.jpg)](/images/2019/04/hybrid_2.jpg)

<figcaption>

SCCM Client Setting for Windows 10 Device Registration

</figcaption>

</figure>

You may also wish to consider updating your golden image to avoid an unexpected device registration in Azure AD. This can occur if there is a delay in your devices applying the a GPO or SCCM Client Setting.

#### Client Firewall Configurations

**Me:** "Do you use a Proxy Server?"  
**You:** "Yes Ben"  
**Me:** "Ok... listen very carefully"  
  
Windows 10 Device Registration occurs either at Computer Startup or User Logon. Both use the SYSTEM context to attempt a device registration in Azure. The SYSTEM has permissions to authenticate against Azure AD because it will have (hopefully) been issued an Access Token by ADFS. Most environments use an explicit Proxy or PAC file to configure **USER** access to the internet via the Proxy Server. Often, the device is overlooked. If you don't already allow the Device to connect to the internet in the SYSTEM context, you will need to make some changes.

**What URLS do my Devices need to connect to?**

- https://enterpriseregistration.windows.net
- https://login.microsoftonline.com
- https://device.login.microsoftonline.com
- Your organization's STS (federated domain/s)

Source: [https://docs.microsoft.com/en-us/azure/active-directory/devices/hybrid-azuread-join-federated-domains](https://docs.microsoft.com/en-us/azure/active-directory/devices/hybrid-azuread-join-federated-domains)  
  
Microsoft provide a Web Service for Office 365 URLs and IPs. Go and see what CIDR and IP's you need to allow for your device to access the above URLS:- 
  
[https://docs.microsoft.com/en-us/office365/enterprise/office-365-ip-web-service](https://docs.microsoft.com/en-us/office365/enterprise/office-365-ip-web-service)  
  
**\*IMPORTANT\*** The CIDR that isn't listed in the Web Service XML, and most definitely is required is:- 
  
**CIDR 40.64.0.0/13** (enterpriseregistration.windows.net)  

### Running the Azure AD Connect Configuration Wizard

You will require:- 

- Azure AD Global Administrator credentials
- Enterprise Administrator credentials for your forest/s
- ADFS Administrator credentials

1 . Open Azure AD Connect and click **Configure**

<figure>

[![](/images/2019/04/hybrid_4.jpg)](blob:https://byteben.com/4b99078d-0601-477d-b3fe-977421a37e91)

<figcaption>

Click "Configure"

</figcaption>

</figure>

2 . Select **Configure Device Options** and click **Next**

<figure>

[![](/images/2019/04/hybrid_5.jpg)](blob:https://byteben.com/40e3bdfe-d29d-43bd-8c9c-01ea5e8dd2ab)

<figcaption>

Select "Configure Device Options"

</figcaption>

</figure>

3 . Read the **Overview** and click **Next**

<figure>

[![](/images/2019/04/hybrid_6.jpg)](blob:https://byteben.com/17ca2aae-6b38-4a23-a188-1f1490e5e518)

<figcaption>

Read the Overview

</figcaption>

</figure>

4 . Enter the **Credentials** of an **_Azure AD Global Administrator_** and click **Next**

<figure>

![](/images/2019/04/hybrid_7.jpg)

<figcaption>

Enter Azure AD Global Administrator Credentials

</figcaption>

</figure>

5 . On the Device Options page, ensure **Configure Hybrid Azure AD Join** is selected and click **Next**

<figure>

![](/images/2019/04/hybrid_8.jpg)

<figcaption>

Choose "Configure Hybrid Azure AD Join"

</figcaption>

</figure>

6 . **Select** the Forest/s to configure, **choose** the ADFS Server, **Add** Enterprise Admin credentials for the Forest/s and click **Next**

<figure>

![](/images/2019/04/hybrid_9.jpg)

<figcaption>

Configure the Service Connection Point

</figcaption>

</figure>

7 . **Choose** which devices you want to support for Hybrid Azure AD Join and click **Next** (we are only looking at Windows 10 devices in this post)

<figure>

![](/images/2019/04/hybrid_10.jpg)

<figcaption>

Choose "Windows 10 o later domain-joined devices"

</figcaption>

</figure>

8 . Enter the **Credentials** of an ADFS Administrator and click **Next**

9 . Review the changes that are about to be made and click **Configure**

<figure>

![](/images/2019/04/hybrid_12.jpg)

<figcaption>

Review the changes before completing the configuration wizard

</figcaption>

</figure>

10 . Configuration Complete, click **Exit**

<figure>

![](/images/2019/04/hybrid_13.jpg)

<figcaption>

Configuration Complete

</figcaption>

</figure>

### Review changes made by the Azure AD Connect Wizard

The Azure AD Connect wizard will have made two changes:-

1. Your Active Directory Configuration will have a new Services Connection Point configured
2. ADFS will have new Claims Trusts configured

#### Verify the Service Connection Point (SCP)

The SCP will tell devices which Azure AD tenant to go and attempt to register on. Connect to your Configuration Naming Context using ADSI EDIT, you will see some new configuration objects

<figure>

![](/images/2019/04/hybrid_14.jpg)

<figcaption>

New Configuration Objects

</figcaption>

</figure>

Clicking on the properties of the object **CN=62a0ff2e-97b9-4513-943f-0d221bd30080** and navigate to the keywords attribute. The two attributes will be unique to your configuration:-

- **azureaADid** Your Azure AD Tenant ID
- **azureADName** Your Azure AD Tenant Domain Name

<figure>

![](/images/2019/04/hybrid_15.jpg)

<figcaption>

Verify the SCP has been created

</figcaption>

</figure>

#### Verify the Claims Trusts

Your Domain Joined Windows 10 Devices rely on ADFS to authenticate to Azure AD in a Federated Domain. Devices will authenticate to get an access token to register against the Azure Active Directory Device Registration Service (Azure DRS).

> When you're using AD FS, either **adfs/services/trust/13/windowstransport** or **adfs/services/trust/2005/windowstransport** must be enabled. If you're using the Web Authentication Proxy, also ensure that this endpoint is published through the proxy. You can see what endpoints are enabled through the AD FS management console under **Service** > **Endpoints**.
> 
> Source: Microsoft  

The following claims must exist in the token passed to Azure AD during Device Registration:-

1. http://schemas.microsoft.com/ws/2012/01/accounttype
2. http://schemas.microsoft.com/identity/claims/onpremobjectguid
3. http://schemas.microsoft.com/ws/2008/06/identity/claims/primarysid
4. http://schemas.microsoft.com/ws/2008/06/identity/claims/issuerid _(If you have more than one verified domain)_
5. http://schemas.microsoft.com/LiveID/Federation/2008/05/ImmutableID _(If you already issue an ImmutableID claim e.g. Alternate Login ID)_

**1 . http://schemas.microsoft.com/ws/2012/01/accounttype**

_@RuleName = "Issue account type for domain-joined computers"  
c:\[  
Type == "http://schemas.microsoft.com/ws/2008/06/identity/claims/groupsid",  
Value =~ "-515$",  
Issuer =~ "^(AD AUTHORITY|SELF AUTHORITY|LOCAL AUTHORITY)$"  
\]  
\=> issue(  
Type = "http://schemas.microsoft.com/ws/2012/01/accounttype",  
Value = "DJ"  
);_  

**2 . http://schemas.microsoft.com/identity/claims/onpremobjectguid**

_@RuleName = "Issue object GUID for domain-joined computers"  
c1:\[  
Type == "http://schemas.microsoft.com/ws/2008/06/identity/claims/groupsid",  
Value =~ "-515$",  
Issuer =~ "^(AD AUTHORITY|SELF AUTHORITY|LOCAL AUTHORITY)$"  
\]  
&&  
c2:\[  
Type == "http://schemas.microsoft.com/ws/2008/06/identity/claims/windowsaccountname",  
Issuer =~ "^(AD AUTHORITY|SELF AUTHORITY|LOCAL AUTHORITY)$"  
\]  
\=> issue(  
store = "Active Directory",  
types = ("http://schemas.microsoft.com/identity/claims/onpremobjectguid"),  
query = ";objectguid;{0}",  
param = c2.Value  
);_

**3 . http://schemas.microsoft.com/ws/2008/06/identity/claims/primarysid**

_@RuleName = "Issue objectSID for domain-joined computers"  
c1:\[  
Type == "http://schemas.microsoft.com/ws/2008/06/identity/claims/groupsid",  
Value =~ "-515$",  
Issuer =~ "^(AD AUTHORITY|SELF AUTHORITY|LOCAL AUTHORITY)$"  
\]  
&&  
c2:\[  
Type == "http://schemas.microsoft.com/ws/2008/06/identity/claims/primarysid",  
Issuer =~ "^(AD AUTHORITY|SELF AUTHORITY|LOCAL AUTHORITY)$"  
\]  
\=> issue(claim = c2);_

**4 . http://schemas.microsoft.com/ws/2008/06/identity/claims/issuerid**

_@RuleName = "Issue account type with the value User when its not a computer"  
NOT EXISTS(  
\[  
Type == "http://schemas.microsoft.com/ws/2012/01/accounttype",  
Value == "DJ"  
\]  
)  
\=> add(  
Type = "http://schemas.microsoft.com/ws/2012/01/accounttype",  
Value = "User"  
);  
@RuleName = "Capture UPN when AccountType is User and issue the IssuerID"  
c1:\[  
Type == "http://schemas.xmlsoap.org/claims/UPN"  
\]  
&&  
c2:\[  
Type == "http://schemas.microsoft.com/ws/2012/01/accounttype",  
Value == "User"  
\]  
\=> issue(  
Type = "http://schemas.microsoft.com/ws/2008/06/identity/claims/issuerid",  
Value = regexreplace(  
c1.Value,  
".+@(?.+)",  
"http://${domain}/adfs/services/trust/"  
)  
);  
@RuleName = "Issue issuerID for domain-joined computers"  
c:\[  
Type == "http://schemas.microsoft.com/ws/2008/06/identity/claims/groupsid",  
Value =~ "-515$",  
Issuer =~ "^(AD AUTHORITY|SELF AUTHORITY|LOCAL AUTHORITY)$"  
\]  
\=> issue(  
Type = "http://schemas.microsoft.com/ws/2008/06/identity/claims/issuerid",  
Value = "http://<_**_verified-Domain-Name_**_\>/adfs/services/trust/"  
);_

**5 . http://schemas.microsoft.com/LiveID/Federation/2008/05/ImmutableID**

_@RuleName = "Issue ImmutableID for computers"  
c1:\[  
Type == "http://schemas.microsoft.com/ws/2008/06/identity/claims/groupsid",  
Value =~ "-515$",  
Issuer =~ "^(AD AUTHORITY|SELF AUTHORITY|LOCAL AUTHORITY)$"  
\]  
&&  
c2:\[  
Type == "http://schemas.microsoft.com/ws/2008/06/identity/claims/windowsaccountname",  
Issuer =~ "^(AD AUTHORITY|SELF AUTHORITY|LOCAL AUTHORITY)$"  
\]  
\=> issue(  
store = "Active Directory",  
types = ("http://schemas.microsoft.com/LiveID/Federation/2008/05/ImmutableID"),  
query = ";objectguid;{0}",  
param = c2.Value  
);_

You can read more about the issuance of claims, and the configuration required/created by the Azure AD Connect wizard at:- 
  
[https://docs.microsoft.com/en-us/azure/active-directory/devices/hybrid-azuread-join-manual#set-up-issuance-of-claims](https://docs.microsoft.com/en-us/azure/active-directory/devices/hybrid-azuread-join-manual#set-up-issuance-of-claims)  

### Did it work?

If we have used due diligence then we should start to see some successful device registrations in Azure AD.

<figure>

![](http://byteben.com/bb/images/2019/04/hybrid_0-1024x154.jpg)

<figcaption>

Hybrid Azure AD Joined Devices

</figcaption>

</figure>

There is no "Owner" when a Windows 10 device registers in Azure AD. Windows "Down-Level" devices e.g. Windows 7 will register with an owner. Careful consideration should be made as each down-level device registration will contribute to the users "Device Limit" (Default 20 devices).

You can also use the cmdlet **Get-MSOLDevice** to view Azure AD Hybrid Joined Devices

```
Get-MsolDevice -all | Where-Object {$_.DeviceTrustType -eq 'Domain Joined' -and $_.DeviceOSType -like "Windows 10*"} | Select DisplayName, DeviceTrustType, DevisOSType
```

<figure>

![](/images/2019/04/hybrid_16.jpg)

<figcaption>

Get-MSOLDevice

</figcaption>

</figure>

### Conclusion

In this post we looked at how we can register our on-premises, Windows 10 devices, with Azure AD - a process also known as "Hybrid Azure AD Join". The main points we focused on were:-

1. Setup the necessary GPO/Client Setting to control Azure Device Registration for Windows 10 Devices
2. Ensure the correct Firewall Configuration is in place to allow Devices to communicate and register in Azure AD
3. Check the pre-requisites and roles required to configure Azure AD Hybrid Join
4. Use the Azure AD Connect wizard to create the ADFS claims and Service Connection Point (SCP)

The next step being considered by many is removing ADFS if its sole role is providing authentication to Office 365 services and replacing it with Azure AD Seamless Single Sign-On - a great feature!  
  
I feel another blog post coming on ;)