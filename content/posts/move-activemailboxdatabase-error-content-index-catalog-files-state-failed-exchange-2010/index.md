---
title: "Move-ActiveMailboxDatabase Error: Content index catalog files in the following state: 'Failed' Exchange 2010"
date: 2014-01-26
tags: ["contentindexstate", "dag", "exchange-2010", "index-catalog", "microsoft", "move-activemailboxdatabase", "powershell", "update-mailboxdatabasecopy"]
categories: ["microsoft", "microsoft-exchange"]
---

So we came across this when attempting a "Move-ActiveMailboxDatabase" powershell command to mount a mailbox database copy in our DAG. We have a powershell script that mounts all DBS on one exchange server so we can do maintenance on the other. <!--more-->

Some Database copies were not mounting and the powershell cmdlet displayed something similar to the following error:-

_An Active Manager operation failed. Error: The database action failed. Error: An error occurred while trying to validate the specified database copy for possible activation. Error: Database copy ‘mydb′ on server ‘myexchserver1’ has content index catalog files in the following state: ‘Failed’. \[Database: mydb, Server: myexchserver2\]_

_An Active Manager operation failed. Error: An error occurred while trying to validate the specified database copy for possible activation. Error: Database copy ‘mydb′ on server ‘myexchserver1’ has content index catalog files in the following state: ‘Failed’._

So we can understand from this error that the Index Catalog on the destination exchange server mailbox database is corrupt. One of the first things we tried was to run the "Get-MailboxDatabaseCopyStatus" powershell command to check the status of the catalog:-

```
Get-MailboxDatabaseCopyStatus | fl name, contentindexstate
```

Name : mydb\\myexchangeserver1  ContentIndexState : Failed

So we can see we definitely have  a failed index on our mailbox database.

There are a couple of ways to reseed the Index as described in [this](http://technet.microsoft.com/en-us/library/ee633475.aspx) Microsoft Technet KB. The following method fixed our catalog:-

```
Update-MailboxDatabaseCopy -Identity mydb\myexchangeserver1 -CatalogOnly
```

This powershell command will reseed the Index Catalog from any available exchange server in the DAG. To be more specific, you can target a specific exchange server by running:-

```
Update-MailboxDatabaseCopy -Identity mydb\myexchangeserver1 -SourceServer myexchangeserver2 -CatalogOnly
```

Re-run the Get-MailboxDatabaseCopyStatus cmdlet as above and your index catalog should now be healthy.

There are other methods to rebuild the index catalog, one common approach is to delete the index catalog folder and restart the Exchange Search Service on the Exchange Server. Google this method to learn more, I don't cover it here, sorry.

Hope it helps.