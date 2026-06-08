---
title: "Cannot send or receive mail on Blackberry Device for mailbox on newly created Exchange 2010 Database"
date: 2014-01-25
categories:
  - "Microsoft"
  - "Microsoft Exchange"
tags: ["bes-permissions", "besadmin", "byod", "database-permissions", "exchange-2010", "iemstest-exe", "mailboxdatabase", "microsoft-exchange"]
---

So you created a new Exchange 2010 Mailbox Database but all mailbox users you move to or create in this database cannot send or receive mail on their Blackberry device?  Permissions, permissions, permissions...<!--more-->

We came across this problem in our Microsoft Exchange 2010 environment. We are part way through migrating from Exchange 2003 to Exchange 2010. We created a new mailbox database to move some remaining service accounts into which included an account used for one of our "support" blackberry devices.

Permissions, permissions, permissions. We found, after running IEMSTest.exe (**C:\\Program Files (x86)\\Research In Motion\\BlackBerry Enterprise Server\\Utility) -** more details [here](http://btsc.webapps.blackberry.com/btsc/viewdocument.do;jsessionid=5DC8A8AE956FC566927BD7DBD426A0C1?externalId=KB31053&sliceId=2&cmd=displayKC&docType=kc&noCount=true&ViewedDocsListHelper=com.kanisa.apps.common.BaseViewedDocsListHelperImpl)) that access was denied when interrogating the users mailbox with the BES service account. As per the Blackberry KB [here](http://btsc.webapps.blackberry.com/btsc/viewdocument.do?externalId=KB02276&sliceId=2&cmd=displayKC&docType=kc&noCount=true&ViewedDocsListHelper=com.kanisa.apps.common.BaseViewedDocsListHelperImpl "Blackberry KB") we needed to add permissions on the new mailbox database for our BES Admin service account.

In your Exchange 2010 environment, you can use the following powershell command to assign the correct permissions for your BES service account. In this example, we shall assume your BES service account is called "BESAdmin" and your mailbox database is called "mynewdb"

```
Get-MailboxDatabase -Identity "MyNewDB" | Add-ADPermission -User "BESAdmin" -AccessRights ExtendedRight -ExtendedRights Receive-As, ms-Exch-Store-Admin, ms-Exch-Store-Visible
```

[![Cannot send or receive mail on Blackberry Device for mailbox on newly created Exchange 2010 Database](/images/2014/01/Cannot-send-or-receive-mail-on-Blackberry-Device-for-mailbox-on-newly-created-Exchange-2010-Database-1024x66.jpg)](http://byteben.com/bb/images/2014/01/Cannot-send-or-receive-mail-on-Blackberry-Device-for-mailbox-on-newly-created-Exchange-2010-Database.jpg)That's it. In the words of Justin Timberlake, mail should now start to "flow like a river".

IEMSTest.exe is your first stop to diagnosing any mailbox access issues for a Blackberry device. This article may be useful for anyone having similar issues with other BYOD mail solutions where a proxy account is used to send and receive mail for the user.

Hope this helps.