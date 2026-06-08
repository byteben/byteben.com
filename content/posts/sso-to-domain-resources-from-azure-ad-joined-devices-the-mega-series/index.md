---
title: "SSO to domain resources from Azure AD Joined Devices - The MEGA Series"
date: 2021-08-15
tags: ["aovpn", "hybrid-domain-join", "kerberos", "ndes", "nps", "rras", "scep", "sso"]
categories: ["azure", "certificates", "identity", "intune", "microsoft", "rssexclude", "windows-10"]
---

Welcome to this new blog series which will hopefully demystify SSO to domain resources from Azure AD Joined devices - and get you up and working quickly with a comprehensive guide on AOVPN configuration.

<!--more-->

Over the coming weeks, we will explore the concept of authenticating users to domain resources from an Azure AD Joined device. This first post in the series will give an overview of how SSO to domain resources works from an Azure AD Joined device.

Many organizations still question how best to achieve this and often try "Hybrid Azure AD Join" for their devices - which is absolutely not a requirement. If you already have a VPN connection - great, most of your work has been done. For those who are still considering how to make a VPN connection, we will walk through how to deploy a Microsoft Always On VPN (AOVPN) solution with the other necessary components and configuration including, Network Policy Server (NPS), Routing and Remote Accesses (RRAS), Extensible Authentication Protocol (EAP), Network Device Enrollment Service (NDES), Simple Certificate Enrollment Protocol (SCEP) and Microsoft Endpoint Manager Intune.

There will be an assumption that you already have a Certificate Authority present in your domain and are running Azure AD Connect to synchronize your user identities to Azure AD.

In summary, the 9 part series will cover:

1. **[SSO to domain resources from Azure AD Joined Devices](https://msendpointmgr.com/2021/08/15/sso-to-domain-resources-from-azure-ad-joined-devices-the-mega-series/)**
2. Configure Certificates for an Always On VPN (AOVPN) solution
3. Set up a Network Policy Server for Routing and Remote Access authentication (NPS)
4. Configure a Routing and Remote Access Server (RRAS)
5. Set up a Device Enrollment Service (NDES)
6. Install Azure AD Application Proxy to publish the Device Enrollment Service (NDES)
7. Configure Certificate Templates in Intune
8. Create a Simple Certificate Enrollment Protocol (SCEP) Profile in Intune
9. Creating the Always On VPN Profile in Intune

## **SSO to domain resources from Azure AD Joined Devices**

Part 1 of 9 from the "SSO to domain resources from Azure AD Joined Devices - The MEGA Series"

This first part of our mega-series will give an overview of how SSO to domain resources works from an Azure AD Joined device. In other words, how to access legacy systems from a pure cloud computer seamlessly (the user won't even know what hit them).

### Why do we need SSO to domain resources from an Azure AD joined device?

Many organizations are now in "full swing" when it comes to the implementation of the Microsoft Cloud offering. We have seen rapid adoption of Cloud technology to allow the workforce to "work from anywhere". Microsoft Teams alone saw a 775% increase in usage, in Italy, during the start of the COVID-19 pandemic in 2020. IT Admins have been among the many hundreds of unsung hero's during the pandemic - often having to turn around new cloud technology in a coffee break. Giving customers access to cloud services from their homes was a big win. Many companies are now questioning the requirement to bring everyone back into the Office and instead are considering a hybrid approach to their workforce's location.

VPN's have played a large part in enabling the workforce to access on-premises resources during the pandemic. More often than not this was to enable them to access file servers and Line of Business applications that were hosted inside the company's datacentres. Some companies have invested more time to remove the requirement of VPN by moving file shares to SharePoint Online and leveraging Azure AD Application Proxy to publish their internal web applications to their users working from home. However, some business applications are just not "Cloud" ready and the VPN is still a requirement to access those on-premises resources. This leaves one big question...

### Do we need Hybrid Azure AD joined devices?

Interesting question. Hybrid Azure AD joined devices are joined to your on-premises Active Directory and registered with Azure Active Directory. If you answer YES to any of the following scenarios then you "might" consider Hybrid Azure AD joined devices:

- You:
    - support down-level devices running Windows 7 and 8.1.
    - want to continue to use Group Policy to manage device configuration.
    - want to use existing imaging solutions to deploy and configure devices.
        - NB: Depending on your skills, you can add Azure AD join to an exisitng imaging solution.
    - have Win32 apps deployed to these devices that rely on Active Directory machine authentication.
    - are provisioning Windows 365 Enterprise Cloud PC's.
    - rely heavily on DFS using a public root domain.

The above list is a revision of what Microsoft are currently writing in the official DOCS at: [https://docs.microsoft.com/en-us/azure/active-directory/devices/concept-azure-ad-join-hybrid#scenarios](https://docs.microsoft.com/en-us/azure/active-directory/devices/concept-azure-ad-join-hybrid#scenarios)

In our experience, the main reason customers are considering Hybrid Azure AD joined devices is if an application requires machine authentication in Active Directory. Actually, it doesn't even have to be an application. If your users are required to access data on a resource computer in another forest, like a file share, then you will probably need to consider Hybrid Azure AD join for your devices.

More information on how Kerberos-based processing of authentication requests works over forest trusts can be found in the DOCS at: [https://docs.microsoft.com/en-us/azure/active-directory-domain-services/concepts-forest-trust#kerberos-based-processing-of-authentication-requests-over-forest-trusts](https://docs.microsoft.com/en-us/azure/active-directory-domain-services/concepts-forest-trust#kerberos-based-processing-of-authentication-requests-over-forest-trusts)

#### The cloud is a candy shop

And the world is not black and white. So feel free to mix both hybrid join and Azure AD joined devices if you have mixed use-cases throughout your enterprise. If for example, you have sales reps in the field not depending on anything that would require a hybrid joined device, then we suggest that you get your feet wet by migrating those users to Azure AD Joined devices.

#### Group Policy (GPO)

One of the common arguments for requiring Hybrid Azure AD joined devices is the use of GPO. GPO's don't have a place in a modern strategy for Azure AD Joined devices - there, I said it! Microsoft has given us a whole set of tools to configure our Azure AD joined, Windows 10/11 devices with Microsoft Endpoint Manager (MEM):

- Templates
- Settings Catalog
- Proactive Remediations
- PowerShell Scripts
- Custom Configuration Service Provider (CSP)

For the die-hard GPO fans, we can leverage Group Policy Analytics. This allows us to understand which GPO's are not available to MDM providers and may need more consideration on why/how they are used.

After you have exported your on-premises GPO's using the Group Policy Management app you can import the XML to Group Policy Analytics where Intune will automatically analyze the GPO.

<figure>

![](/images/2021/08/image-55.png)

<figcaption>

Export GPO by choosing "Save Report" in the GPMC.msc

</figcaption>

</figure>

<figure>

![](/images/2021/08/image-56-1024x264.png)

<figcaption>

Group Policy Analytics analysis of the imported XML

</figcaption>

</figure>

Group policy analytics is a great tool in understanding which GPO's can be configured in Intune. I would always encourage you to review the GPO's you have in place today. Try and question whether they are needed for Intune managed devices.

Unless you are following a strict baseline for configuration and can vouch for every setting, which cannot be replicated from Intune - great, use your existing strategy for device configuration, which may mean you have to consider a Hybrid Azure AD device join. If not, I would encourage you to look at managing your Azure AD joined devices from a fresh perspective. By all means, start with whatever security baseline applies to your business sector but then pause. Question the processes you have in place and whether they need to be re-considered for modern device management.

### How does AD authentication work from an Azure AD joined device?

This is where we get into the meat of this first blog post.

<figure>

![](/images/2021/08/image-57.png)

<figcaption>

Kerberos authentication from an Azure AD Joined Device

</figcaption>

</figure>

#### Prerequisites

There are not as many smoke and mirrors at play here as you might think. A critical component, which is assumed you have in place, is Azure AD Connect.

Another critical, and obvious assumption is that your device has line-of-sight to your on-premises resources and domain controllers. This will typically be over a VPN for devices that are not on the corporate network. We will go through the configuration of a basic AOVPN setup later in this series.

#### The mechanics of it

Azure AD "is" aware of your domain because it synchronises on-premises user and domain information (attributes) to Azure AD. When a synchronised identity, logs into an Azure AD joined device, Azure AD sends a Primary Refresh Token (PRT) along with the details of the user's on-premises domain to the device. The Local Security Authority (LSA) service will then enable both Kerberos and NTLM authentication protocol on the device. The attributes that were synced with the user identity contain the domain information so now we are seeing a normal Kerberos/NTLM exchange with the domain controllers. That is the magic!

<figure>

![](/images/2021/08/image-93-1024x554.png)

<figcaption>

SSO to domain resources

</figcaption>

</figure>

1. Azure AD Connect synchronizes user identities from Active Directory to Azure Active Directory. Domain identifying attributes are included on the synced user object including, but not limited to, SAM Account Name (used to create the profile path on AAD joined devices), Domain name and UPN.
2. The User on the AAD joined device authenticates to Azure AD and obtains a Primary refresh token. At the same time The "Domain Name" attribute is used by the AAD joined device to locate the Domain Controller and the LSA service enables the Kerberos authentication protocol on the device.
3. Normal Kerberos ticket issuance takes place.
4. Access to a Domain Resource is requested. Kerberos tickets are requested and used to authenticate the request to the resource.

Go and read [@SteveSyfuhs](https://twitter.com/SteveSyfuhs) excellent blog on "How Azure AD Windows Sign-In Works" if you want to go deeper [How Azure AD Windows Sign-in Works (syfuhs.net)](https://syfuhs.net/how-azure-ad-windows-sign-in-works)

#### See it in action

##### Lab: Sign-in

I have an Azure AD Joined device in my lab, connected to the same network as my domain controller. Let's see what happens when I sign in using my Azure AD credentials - remember, this device is not domain-joined but it is aware of my domain via the Azure AD Connect information passed to the device when I obtained my PRT.

![](/images/2021/08/image-58.png)

When I sign in on my client device, I see event 4768 on my Domain Controller. This confirms that my user has been issued a Kerberos ticket. Let's see what that looks like on my client.

<figure>

![](/images/2021/08/image-59.png)

<figcaption>

Klist displays the cached Kerberos tickets

</figcaption>

</figure>

Magic! I don't need to perform ANY configuration to obtain that token. The only pre-requisite was that I had a line of sight with my Domain Controller and the user that I logged into my device with was a "synchronised" identity. That's it!

##### Lab: Accessing files shares

So now when I try and access a Domain resource.... let us try the domain controller...

<figure>

![](/images/2021/08/image-63.png)

<figcaption>

accessing a domain share

</figcaption>

</figure>

My device has sent the on-premises domain information and user credentials to my Domain Controller. I can see that Kerberos tickets have been issued to allow me to access that domain resource

<figure>

![](/images/2021/08/image-62.png)

<figcaption>

Kerberos tickets issued

</figcaption>

</figure>

On my Windows client, I now have the necessary Kerberos ticket(s) to access that share on my domain. If I had tried to access a resource or application that supports NTLM I would have received an NTLM token.

<figure>

![](/images/2021/08/image-61.png)

<figcaption>

I now have 3 cached Kerberos tickets

</figcaption>

</figure>

#### What applications and resources will this magic work for?

We have seen in the above example that Kerberos authentication works. If the application or resource uses NTLM the device would have received an NTLM token - SSO would still have worked. It is worth mentioning that any application that is configured for Windows-Integrated authentication would also work for SSO to domain resources from an Azure AD joined device.

## Caveats

Any good blog post must contain a caveat or two.

### Windows Hello for Business

Many organisations are enabling Windows Hello for Business (WHfB) on their Azure AD Joined devices - this makes perfect sense. I now have to backtrack and add a caveat to my previous statement where I said "I don't need to perform ANY configuration to obtain that token".

If you are using WHfB, you are not logging on with a Username/Password combination. You will be using a biometric or PIN.

<figure>

![](/images/2021/08/image-64.png)

<figcaption>

Logging on with WHfB

</figcaption>

</figure>

WHfB requires additional configuration to enable on-premises SSO from an Azure AD joined device. There are two deployment models, to enable this. The "Key Trust" model and the "Certificate Trust" model. The "Key Trust" model requires a TPM on your device. The "Certificate Trust" model requires your domain to be federated to Azure AD - which is a complex piece of work. As many organisations are trying to move away from ADFS, we will focus on the requirements for the Key Trust model.

#### Key Trust Model

> Why does Windows need to validate the domain controller certificate?
> 
> Windows Hello for Business enforces the strict KDC validation security feature when authenticating from an Azure AD joined device to a domain. This enforcement imposes more restrictive criteria that must be met by the Key Distribution Center (KDC)

How Key based authentication works: -

1. Authentication begins when when the user first makes an attempt to access a resource that requires Kerberos authentication. The Security Support Provider (SSP) uses metadata from the Hello key to get a hint of the user domain.
2. Using the hint, the provider uses the DClocator service to locate a **2016** Domain Controller.
3. The SSP uses the private key to sign the Kerberos pre-auth data.
4. The Kerberos SSP sends the signed pre-auth key and its public key (as a certificate) to the KDC.
5. The KDC determines the certificate is self signed. It retrieves the public key and searches for it in Active Directory.
6. The Domain Controller validates the UPN for authentication and returns a (Ticket Granting Ticket) TGT to the client with its certificate.

Public key mapping is only supported by Windows Server 2016 domain controllers and above

Further reading on how AAD joined devices authenticate to Active DIrecotry using a Key can be found below

[https://docs.microsoft.com/en-us/windows/security/identity-protection/hello-for-business/hello-how-it-works-authentication#azure-ad-join-authentication-to-active-directory-using-a-key](https://docs.microsoft.com/en-us/windows/security/identity-protection/hello-for-business/hello-how-it-works-authentication#azure-ad-join-authentication-to-active-directory-using-a-key)

To summarise the above information, in order to allow authentication using WHfB, domain controller certificates must be updated to include the **KDC Authentication** EKU. More reading and implementation for this can be found in the links below.

[https://docs.microsoft.com/en-us/windows/security/identity-protection/hello-for-business/hello-hybrid-aadj-sso-base](https://docs.microsoft.com/en-us/windows/security/identity-protection/hello-for-business/hello-hybrid-aadj-sso-base)

[https://docs.microsoft.com/en-us/windows/security/identity-protection/hello-for-business/hello-hybrid-key-whfb-settings-pki](https://docs.microsoft.com/en-us/windows/security/identity-protection/hello-for-business/hello-hybrid-key-whfb-settings-pki)

**Note:** Windows Hello for Business with a key does not support supplied credentials for RDP. RDP does not support authentication with a key or a self signed certificate. RDP with Windows Hello for Business is supported with certificate based deployments as a supplied credential.

[https://docs.microsoft.com/en-us/windows/security/identity-protection/hello-for-business/hello-overview#comparing-key-based-and-certificate-based-authentication](https://docs.microsoft.com/en-us/windows/security/identity-protection/hello-for-business/hello-overview#comparing-key-based-and-certificate-based-authentication)

#### Put your money where your mouth is

Once you have modified your Domain Controller Authentication templates to include the EKU "KDC Authentication" and distributed as per the MS DOC above, your new Domain Controller Authentication certificate should have the KDC EKU.

<figure>

![](/images/2021/08/image-94.png)

<figcaption>

Domain Controller Authentication Template EKU includes KDC

</figcaption>

</figure>

You can login to Windows with WHfB and be issued with Kerberos tickets

<figure>

![](/images/2021/08/image-97.png)

<figcaption>

Kerberos Ticket pre-auth issuance using Key Trust

</figcaption>

</figure>

<figure>

![](/images/2021/08/image-96.png)

<figcaption>

Kerberos Ticket issuance using Key Trust

</figcaption>

</figure>

Remember that before you issue the new Domain Controller Authentication Certificate to your DCs, a valid HTTP Certificate Revocation Point should be available for your WHfB devices.

### DFS Shares

DFS is great for redirecting resources, and it is fully supported for Azure AD Joined devices. But you might run into a few snags when access is done over a split-tunnel VPN.

For Kerberos SSO to work, you might be aware that it uses DNS, so you will have to use a Fully Qualified Domain Name (FQDN) to access the file shares on a DFS Namespace (e.g. \\\\dfs.contoso.com\\fileshare1\\), this goes for the servers that the Namespace is redirecting to as well, everything should be configured with FQDN. Microsoft has some good info on converting your namespace to using FQDN at: [](https://docs.microsoft.com/en-US/troubleshoot/windows-server/networking/configure-dfs-use-domain-names)[https://docs.microsoft.com/en-US/troubleshoot/windows-server/networking/configure-dfs-use-domain-names](https://docs.microsoft.com/en-US/troubleshoot/windows-server/networking/configure-dfs-use-domain-names)

Here is a small PowerShell tool to make the conversion a little less tedious: [https://github.com/mardahl/PSBucket/blob/master/Convert-DFSn2FQDN](https://github.com/mardahl/PSBucket/blob/master/Convert-DFSn2FQDN)

If you are the lucky admin of a DFS Namespace using FQDN with a root domain that is also your firm's public website (e.g. contoso.com), then you must take care to get all the routing via split-tunnel in place. Otherwise, you can obviously end up hitting the public website IP.

## Summary

This first post in the series was designed to inform you that SSO is possible, to domain resources, from an Azure AD joined device WITHOUT requiring Hybrid Azure AD Join.

Microsoft has done some great work in making this feature just work - let's spread the word, SSO to domain resources is EASY.

Modern management of devices makes sense to me. Yes, there are still use cases for devices to access domain resources via VPN but as more vendors start moving the authentication model for their applications to support modern authentication methods I see this becoming less of a requirement over the next 5-10 years.

Special thanks to **Daniel Stefaniak** and **[Steve Syfuhs](https://syfuhs.net/steve)** at Microsoft for being awesome people willing to give time to help the community with olive branches and blog posts and also to [Michael Mardahl](https://msendpointmgr.com/author/michaelm/) for jumping in with some great co-authoring and additions.

See you in Part 2 where we will **Configure Certificates for an Always On VPN (AOVPN) solution**