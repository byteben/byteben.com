---
title: "O365 - How to add a mail.onmicrosoft.com smtp address using PowerShell"
date: 2018-07-28
categories:
  - "Microsoft"
  - "Microsoft Exchange"
  - "Office 365"
  - "Scripts"
tags: ["exchange-address-book-policy", "mail-onmicrosoft-com", "o365", "powershell", "tenant"]
categories: ["microsoft", "microsoft-exchange", "office365", "scripts"]
---

So you are on-boarding user mailboxes to Exchange Online and your user does not have a <domain>.mail.onmicrosoft.com smtp address. STOP. Your mailbox migration will fail without it. (Maybe you know this and this is why you are here :) )

<!--more-->

If you used the Exchange Hybrid Configuration Wizard, by default, <domain>.mail.onmicrosoft.com) is added as a secondary proxy domain to any email address policy which specifies the_PrimarySmtpAddress_.

As stated, a missing <domain>.mail.onmicrosoft.com smtp address will cause the mailbox migration to fail.

Q: But we ran the Hybrid Configuration wizard. All our users have this additional <domain>.mail.onmicrosoft.com smtp address right?

A: Your users will have a <domain>.mail.onmicrosoft.com smtp address if they have a magic check box selected in their mailbox properties "Automatically update email addresses based on the email address policy applied to this recipient"

![](http://byteben.com/bb/images/2018/07/emailaddresspolicy.jpg)

or, in older versions of the EMC, "Automatically update e-mail addresses based on e-mail address policy".

 

![](http://byteben.com/bb/images/2018/07/emailaddresspolicyemc.jpg)

If they do not, the <domain>.mail.onmicrosoft.com smtp address that was specified when you ran the Hybrid Configuration Wizard will not apply to that user.

Go ahead and check this box and your user will get the desired <domain>.mail.onmicrosoft.com smtp address. BUT..This box may have been left deselected for specific users for particular reasons. If so, you can manually add the <domain>.mail.onmicrosoft.com smtp address using the Set-ADUser cmdlet (Requires the Active Directory PowerShell module).

```
Set-AdUser wilson.ball -Add @{ProxyAddresses=('smtp:wilson.ball@contoso.mail.onmicrosoft.com')}
```

After you run the above command your user will have the required <domain>.mail.onmicrosoft.com smtp address for the mailbox migration prerequisite.

![](http://byteben.com/bb/images/2018/07/set-aduseraddemail.jpg)

Ensure the updated user identity is synced to Azure AD before you attempt the mailbox migration.

 

We will look at migrating users to Exchange Online in our next post.