---
title: "Azure AD Groups - in a nutshell"
date: 2020-04-13
tags: ["azure-ad", "dynamic-group", "group", "office-365-group", "powershell"]
categories: ["azure", "identity", "intune", "microsoft", "office365", "scripts"]
---

Not the longest post in the world but "Groups" are going to be quite pivotal in how you manage users and devices in Azure AD. In this post we will cover the basic Azure AD group and membership types. We will also look at how we can create Groups in both the Azure AD Portal and by using PowerShell.

<!--more-->

We will cover:-

1. [What is a Group and why should we use one](#WhatisaGroup)
2. [Group Types](#GroupTypes)
3. [Group Membership](#GroupMembership)
4. [Create a Group in the Azure AD Portal](#CreateaGroupinAzureAD)
5. [Create a Group using PowerShell](#CreateaGroupPowerShell)

### 1 . What is a Group and why should we use one [⏏](#NavMenu)

If you are reading this post, the chances are that you are fairly new to Azure AD. Like many of us, when we spin up our first tenant we assign resources to our test user/s. As we get more familiar with the products, assigning users to resources becomes more onerous. Many of us will have some kind of background in Active Directory and understand that we use Active Directory Groups to assign resources to users in our domain.

Azure AD is no different, the concept is identical. We assign users (or members) to groups and assign resources to those groups. Azure AD Groups have features that set them apart from their Active Directory cousins - we will go through these features in the following sections.

### 2 . Group Types [⏏](#NavMenu)

As of writing this post, we can create two types of Groups in Azure AD

- **Security**
- **Office 365**

![](/images/2020/04/image-18.png)

**Security Groups**

A Security Group will be used to collectively assign resources to users. For example, assigning Intune Configuration Policies. If we assign resources to Users, we have to manually update each resource assignment whenever we want to make a change. By using a Security Group, we assign the resource to the Group once and adjust the Group members to reflect who has access to the resource.

**Office 365 Groups**

An Office 365 Group will give any group member access to a Group email address (specified during creation) and SharePoint Site and is best suited for when collaboration is required between both internal and/or external users. Office 365 Group are one of the underpinning technologies of Microsoft Teams. Think of them like the traditional Active Directory mail enabled-security groups - with a "Nitro" button.

### 3 . Group Membership [⏏](#NavMenu)

This is where we set apart the differences between Active Directory and Azure AD Groups IMO. There are three different membership types availble to Azure AD Groups, depending on what Group type you choose to create

- **Assigned**
- **Dynamic User**
- **Dynamic Device**

![](/images/2020/04/image-19.png)

Before we go into each of these Membership types, let us first establish when they can or cannot be used.

|  | **Security Group** | **Office 365 Group** |
| --- | --- | --- |
| **Assigned** | Yes | Yes |
| **Dynamic User** | Yes | Yes |
| **Dynamic Device** | Yes | \- |

**Assigned**

An Assigned Group Membership Type indicates that members (users/devices) are manually added or removed from the Group

**Dynamic User**

A Dynamic Group Membership Type allows you to dynamically add or remove users to the Group based on one or many of their account attributes. Once the Membership rules are defined, Users are added/removed dynamically.  

**Dynamic Device**

A Dynamic Device Membership Type is not available for Office 365 Group Types. It allows you to dynamically add or remove Devices to the Group based on one or many of the Device attributes. Once the Membership rules are defined, Devices are added/removed dynamically.

> You can create a dynamic group for either devices or users, but not for both. You also can't create a device group based on the device owners' attributes. Device membership rules can only reference device attributions. For more info about creating a dynamic group for users and devices, see [Create a dynamic group and check status](https://docs.microsoft.com/en-us/azure/active-directory/users-groups-roles/groups-create-rule).
> 
> [https://docs.microsoft.com/en-us/azure/active-directory/fundamentals/active-directory-groups-create-azure-portal](https://docs.microsoft.com/en-us/azure/active-directory/fundamentals/active-directory-groups-create-azure-portal)

Membership rules are defined as expressions. Let's have a look below at an example. You can find a list of supported properties and their values at [https://docs.microsoft.com/en-us/azure/active-directory/users-groups-roles/groups-dynamic-membership#supported-properties](https://docs.microsoft.com/en-us/azure/active-directory/users-groups-roles/groups-dynamic-membership#supported-properties)

You build the expression by selecting the properties and values and choosing **\+ Add Expression**

![](/images/2020/04/image-24-1024x300.png)

In the example above, the Group will include all users who have an enabled account and the "Disable Password Expiration" flag set. You can manually edit the expression by clicking the **Edit button**

![](/images/2020/04/image-25.png)

More information can be found on creating Dynamic Groups at [https://docs.microsoft.com/en-us/azure/active-directory/users-groups-roles/groups-create-rule](https://docs.microsoft.com/en-us/azure/active-directory/users-groups-roles/groups-create-rule)

### 4 . Create a Group in the Azure AD Portal [⏏](#NavMenu)

1 . Navigate to [https://portal.azure.com](https://portal.azure.com), Sign in as a Global Administrator and select **Azure Active Directory**

![](/images/2020/04/image-20.png)

2 . Select **Groups**

![](/images/2020/04/image-21.png)

3 . Select  **+ New Group**

![](/images/2020/04/image-22.png)

4 . Enter the following Information:-

**Group Type:** Security  
**Group Name:** Corporate Twitter Users  
**Membership type:** Assigned  
**Members:** Add some members to the group who will access the corporate social media Twitter app

![](/images/2020/04/image-23.png)

5 . Click **Create**

### 5 . Create a Group using PowerShell [⏏](#NavMenu)

To create Groups using PowerShell, you will need the **Azure AD** PowerShell module. If you have WMF 5 (Windows 10) or the MSI based installer for PowerShell 3 and 4 you can use [PowerShellGet](http://go.microsoft.com/fwlink/?LinkID=760387&clcid=0x409) to install the module.

1 . Install the module from the PowerShell library using the following command. PowerShell will need to be running with local administrator credentials.

```
Install-Module AzureAD
```

![](/images/2020/04/image-26.png)

Choose **A** or **Y** to accept the changes

The module will begin to install

![](/images/2020/04/image-27.png)

2\. Either re-launch PowerShell to import the AzureAD module automatically or run the command **Import-Module AzureAD**

3 . Run **Get-Module AzureAD** to verify the module has installed and loaded

![](/images/2020/04/image-28.png)

4\. To view all the 188 available command in this module, run **Get-Help AzureAD**

![](/images/2020/04/image-29.png)

5\. Before we can run those commands, we have to authenticate our session and connect to to Azure AD. Lets run the following:-

```
$AzureAdCred = Get-Credential
```

When prompted enter your Administrator credentials for Azure AD and click **OK**

![](/images/2020/04/image-31.png)

Now lets connect to Azure AD with these credentials. Lets run the following:-

```
Connect-AzureAD -Credential $AzureAdCred
```

![](/images/2020/04/image-33.png)

6\. Lets create a Security Group with an assigned membership type. We will create the same Group we created in section 4 for our Corporate Twitter Users

```
New-AzureADGroup -DisplayName "Corporate Twitter Users" -MailEnabled $False -SecurityEnabled $True -MailNickName "CorporateTwitterUsers"
```

![](/images/2020/04/image-34.png)

7\. And now we want to add some users to our new Security Group. The cmdlet will require the **ObjectId** of the Group and **ObjectId** of the member/s you are adding, referred to with the **RefObjectId** parameter. Going to grab the **ObjectId** of each member can be laborious but you can pass it much more simply by using the following code:-

```
Add-AzureADGroupMember -ObjectId 146fa3a5-419d-491a-9236-3e283b1c0a57 -RefObjectId (Get-AzureADUser | Where {$_.UserPrincipalName -eq "nickir@byteben.com"}).ObjectID
```

![](/images/2020/04/image-35.png)

or we can iterate through an array of users

```
$Users = @("bricup@byteben.com","cardev@byteben.com","darfos@byteben.com")
ForEach ($User in $Users) {Add-AzureADGroupMember -ObjectId 146fa3a5-419d-491a-9236-3e283b1c0a57 -RefObjectId (Get-AzureADUser | Where {$_.UserPrincipalName -eq $User}).ObjectID}
```

![](/images/2020/04/image-36.png)

and we can view the membership of our group by running the following command

```
Get-AzureADGroupMember -ObjectId 146fa3a5-419d-491a-9236-3e283b1c0a57
```

![](/images/2020/04/image-37.png)

### Summary

That post should give you a nice introduction to Groups in Azure Active Directory (Azure AD). We covered the Group and Membership Types available and how to create groups using the Azure Portal and AzureAD PowerShell module.

Hope to see you next time :)