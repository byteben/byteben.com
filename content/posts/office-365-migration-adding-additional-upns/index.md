---
title: "Office 365 Migration - Adding Additional UPNs"
date: 2018-07-14
categories:
  - "Identity"
  - "Microsoft"
  - "Office 365"
tags: ["identity", "non-routable-domain", "office-365", "upn", "upn-suffix"]
categories: ["identity", "microsoft", "office365"]
---

In my previous post [office-365-migration-user-attribute-discovery-export-powershell/](https://byteben.com/bb/office-365-migration-user-attribute-discovery-export-powershell/) I described the importance of matching your user UPN with their primary SMTP Address.

<!--more-->

A scenario I recently came across was where the customer didnt have the correct UPN Suffix registered in their Active Directory Forest.

For example, the root domain was contoso.com so all their UPNs were similar to john.doe@contoso.com. They also had some users with a Primary SMTP Address of fabrikam.com but their UPN was still contoso.com

### Can I add a UPN to my Forest? Will it destroy things?

Yes. No. The default UPN is created when you birth your Active Directory and it matches the FQDN. Your users can log into domain resources with either their UPN or their SamAccountName. UPN suffixes can be added, by Powershell or the Active Directory Domains and Trusts Snapin.

Adding a UPN Suffix is primarily performed, but not restricted to (see above scenario), for non routable domains (Good MS post [here](https://support.office.com/en-us/article/how-to-prepare-a-non-routable-domain-such-as-local-domain-for-directory-synchronization-e7968303-c234-46c4-b8b0-b5c93c6d57a7) on them) e.g. your domain is contoso.local but you want users to log into resource with john.doe@contoso.com because your verified Office 365 domain is contoso.com. In this scenario you would add contoso.com as a new UPN Suffix in your Active Directory Forest

### How do I add a UPN Suffix?

What do we need to do. Lets assume you have no additional UPN Suffixes and want to add fabrikam.com. The account you use for the following commands requires either "Domain Admin" or "Enterprise Admins" membership. [Read More](https://docs.microsoft.com/en-us/previous-versions/windows/it-pro/windows-server-2008-R2-and-2008/cc772007\(v=ws.11\))

```
Get-ADForest | Select Domains
```

This cmdlet will bring back your current Domain name (and UPN Suffix)

```
Get-ADForest | Select UPNSuffixes
```

Will return nothing. Lets add fabrikam.com as a UPN suffix to our Active Directory Forest

```
Get-ADForest | Set-ADForest -UPNSuffixes @{add="fabrikam.com"}
```

Did it work? Lets see. Run the Get-ADForest cmdlet again

```
Get-ADForest | Select UPNSuffixes
```

All things being well you should see your new UPN Suffix fabrikam.com listed.

### How do I assign the new UPN Suffix to my users?

The new UPN suffix will be available in the Active Directory Users and Computers Snapin. Edit the user and navigate to the Account tab. The "User Logon Name" is the UPN prefix. The drop down box lists the UPN Suffixes available". You should see your new UPN Suffix here.

Powershell fanatic? A great resource has been published by MS, head over to [https://support.office.com/en-us/article/how-to-prepare-a-non-routable-domain-such-as-local-domain-for-directory-synchronization-e7968303-c234-46c4-b8b0-b5c93c6d57a7](https://support.office.com/en-us/article/how-to-prepare-a-non-routable-domain-such-as-local-domain-for-directory-synchronization-e7968303-c234-46c4-b8b0-b5c93c6d57a7)