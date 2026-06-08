---
title: "Office 365 Migration - User Attribute Discovery and Export using Powershell"
date: 2018-07-04
categories:
  - "Identity"
  - "Microsoft"
  - "Microsoft Exchange"
  - "Office 365"
  - "Scripts"
tags: ["hybrid", "migration", "o365", "powershell", "primarysmtp", "upn"]
---

Identity is key. I cannot emphasise this enough as you begin to move workloads into Exchange Online, SharePoint Online and Skye for Business Online. One of the first pieces of advice you should have been given is the user UPN should match the primary SMTP address. Here is why:-

1. The UPN in Office 365 becomes the default SIP address in Skype for Business Online.
2. Office (inc Office for IOS) and OneDrive require the UPN to match the email address.

<!--more-->

For a good place to start sanitising your Active Directory, and if you have not already done so, look into [https://support.office.com/en-us/article/prepare-to-provision-users-through-directory-synchronization-to-office-365-01920974-9e6f-4331-a370-13aea4e82b3e "](https://support.office.com/en-us/article/prepare-to-provision-users-through-directory-synchronization-to-office-365-01920974-9e6f-4331-a370-13aea4e82b3e)

"It’s easy to get **userPrincipalName** (on-premises and in Azure Active Directory) and the primary email address in **proxyAddresses** set to different values. When they are set to different values, there can be confusion for administrators and end users"

Matching UPN to the Primary SMTP **is not** a requirement but it makes things a lot easier for you and your users.

This post is in danger of losing focus so let me get back on track.

I wanted to check the following attributes for users before I consider migrating their mailbox to Exchange Online:-

1. UPN
2. SAM Account Name
3. Primary SMTP Address
4. SMTP Addresses (to see if they had been given a .onmicrosoft.com address)

UPN and Primary SMTP Address are very important to me, i need to ensure these match. I would like to see the Sam Account Name - this is what my users can carry on using to log into on premise apps/computers. I also want to check if my users have been allocated an .onmicrosoft.com smtp address from the Exchange Email Address Policy (Policy created during Exchange Hybrid Configuration - some users have the tick box unchecked "Automatically Update e-mail addresses based on e-mail address policy" and this would have prevented them from getting a user@tenant.mail.onmicrosoft.com address).

One way of checking your user attributes is to use PowerShell. The following script will take information from Active Directory and Exchange On-Premise and output to a CSV.

The script does not modify data, it manipulates objects outputted by the cmdlets and exports the results to a CSV

```
#Filter User query based on name. Replace 'Name -like "A*"' with * to return all Active Directory Users
$Users = get-mailbox -Filter 'Name -like "A*"' | Select Alias, PrimarySmtpAddress

#Iterate through each returned user object
ForEach ($User in $Users){

#Set SmtpAddress variable to nothing
$SmtpAddresses = $Null

#Grab all smtp addresses for user object
$EmailAddresses = Get-mailbox -identity $User.Alias | Select -Expand EmailAddresses | where {$_.prefix -like 'smtp'}

#Set variable to match all smtp addresses for user object and seperate with a semi colon for easier viewing in exported csv
ForEach ($EmailAddress in $EmailAddresses){
$SmtpAddresses += $EmailAddress.AddressString + ';'
}

#Set OnMicrosoftSmtpAddresses variable if any of the returned smtp addresses matches *.onmicrosoft.com
$OnMicrosoftSmtpAddress = get-mailbox $User.Alias | Select -Expand EmailAddresses | Where {$_.AddressString -like "*onmicrosoft.com"} | Select $_.AddressString

#Prepare Export to CSV
Get-ADUser -Filter ('MailNickName -eq "' + $User.Alias + '"') -SearchBase 'ou=users,dc=constoso,dc=com' -properties Name,UserPrincipalName, SamAccountName, GivenName, sn | Select Name,@{Name='First Name';Expression={$_.GivenName}},@{Name='Surname';Expression={$_.sn}},UserPrincipalName,SamAccountName,@{Name='PrimarySmtpAddress';Expression={$User.PrimarySmtpAddress}}, @{Name='SmtpAddresses';Expression={$SmtpAddresses}}, @{Name='OnMicrosoftSmtpAddress';Expression={$OnMicrosoftSmtpAddress.AddressString}} | Export-Csv C:\Migrateusers.csv -NoTypeInformation -Append
}
```

This code should be tested before being applied to a production environment