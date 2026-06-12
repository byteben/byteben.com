---
title: "\"The site database has a backlog of SQL change tracking data\""
date: 2019-07-28
tags: ["backlog", "change-tracking", "configmgr", "current-branch", "prerequisite", "sccm", "site-database", "sql"]
categories: ["configmgr-memcm-sccm", "microsoft", "scripts"]
---

<figure>

<!--more-->

[![](/images/2019/07/sql_tracking_data_1.jpg)](blob:https://byteben.com/2b7bac99-7e2a-4379-8330-8c5d843e4d18)

<figcaption>

The site database has a backlog of SQL change tracking data

</figcaption>

</figure>

One of the more common prerequisite warnings I see when updating SCCM in my lab is:-

> \[Completed with warning\]:The site database has a backlog of SQL change tracking data. For more information, see https://go.microsoft.com/fwlink/?linkid=2027576
> 
> SCCM Update Pack Installation Status

We can see the same warning in **ConfigMgrPreReq.log**

<figure>

[![](/images/2019/07/sql_tracking_data_2-1024x552.jpg)](/images/2019/07/sql_tracking_data_2.jpg)

<figcaption>

**ConfigMgrPreReq.log**

</figcaption>

</figure>

### What does this warning mean?

Starting in SCCM 1810, the in-console update wizard now performs a check to see if the site database has a backlog of SQL change tracking data.

At times of replication or heavy data processing, the oldest value in the **_syscommittab_** table can be over 5 days old (SCCM Default value is 5 days). Microsoft recommend that you clean up any change tracking data over 7 days old.

To verify the prereq warning, we can connect to our SQL Database with a Dedicated Administrator Connection (DAC) by using SQL Server Management Studio (SSMS) or the SQLCMD command line.

We will use SSMS in the following example to check the age of our change tracking data.

### Make a Dedicated Access Connection to SQL via SSMS

The DAC doesn't allow multiple connections and by its very nature, this is what the Object Explorer in SSMS does. Follow the steps below to make a DAC.

1 . Open SSMS and connect to your SCCM Database engine

<figure>

[![](/images/2019/07/sql_tracking_data_16.jpg)](blob:https://byteben.com/e18b124b-5ec0-4067-aff9-28c2bcd80f7b)

<figcaption>

Connect to SQL

</figcaption>

</figure>

2 . Create a new **Database Engine Query**

<figure>

[![](/images/2019/07/sql_tracking_data_17.jpg)](/images/2019/07/sql_tracking_data_17.jpg)

<figcaption>

Create a new Database Engine Query

</figcaption>

</figure>

3 . Modify the connection and prefix the Database with **ADMIN:**

[![](/images/2019/07/sql_tracking_data_18.jpg)](/images/2019/07/sql_tracking_data_18.jpg)

Congratulations, you have made a DAC!

<figure>

[![](/images/2019/07/sql_tracking_data_19.jpg)](/images/2019/07/sql_tracking_data_19.jpg)

<figcaption>

Connection prefixed with ADMIN:

</figcaption>

</figure>

4 . In the DAC query window, enter the following query.

```
USE <ConfigMgr database name>
EXEC spDiagChangeTracking
```

<figure>

[![](/images/2019/07/sql_tracking_data_20.jpg)](/images/2019/07/sql_tracking_data_20.jpg)

<figcaption>

Query should look similar to this

</figcaption>

</figure>

5 . Click **Execute**

<figure>

[![](/images/2019/07/sql_tracking_data_21.jpg)](/images/2019/07/sql_tracking_data_21.jpg)

<figcaption>

Click Execute

</figcaption>

</figure>

The Stored Procedure executes. In the results below the **CT\_DAYS\_OLD** value is **18**

[![](/images/2019/07/sql_tracking_data_22.jpg)](blob:https://byteben.com/1fe1da91-69c0-4156-9ebd-8798b407da9a)

The oldest change tracking data in the syscommittab table for SCCM should be 5 days and Microsoft recommend cleaning up data older than 7 days. 18 days has over stepped the mark somewhat and triggered the warning for the SCCM update prerequisite.

### How do we clean up old change tracking data?

If the auto-cleanup task isn't cleaning up old change tracking data we can clean it up using another builtin stored procedure. Reference [https://docs.microsoft.com/en-us/sccm/core/servers/deploy/install/list-of-prerequisite-checks#bkmk\_changetracking](https://docs.microsoft.com/en-us/sccm/core/servers/deploy/install/list-of-prerequisite-checks#bkmk_changetracking)

1 . Using the same DAC Query window, run the following stored procedure

```
EXEC spDiagChangeTracking @CleanupChangeTracking = 1
```

<figure>

[![](/images/2019/07/sql_tracking_data_23.jpg)](/images/2019/07/sql_tracking_data_23.jpg)

<figcaption>

Enter the stored procedure

</figcaption>

</figure>

2 . Click **Execute**

So that's it right? It would be my expectation that **CT\_Days\_Old** value would decrease. If yours did..job done, re-run the SCCM prerequisites check and enjoy the green ticks. End of Blog Post.......

### Digging Deeper

Didn't work? Take a look below. My syscommittab table still has change tracking data that is **18** days old in my lab environment!

<figure>

[![](/images/2019/07/sql_tracking_data_24.jpg)](blob:https://byteben.com/d793881c-cabf-4a5d-a990-78f7cb0762df)

<figcaption>

Nothing happened

</figcaption>

</figure>

So i sat scratching my head. Lets look to see if auto cleanup is enabled for our database. Kendra Little over at @BrentOzarULTD Blog Page has an excellent blog post if you want to find out more [https://www.brentozar.com/archive/2014/06/performance-tuning-sql-server-change-tracking/](https://www.brentozar.com/archive/2014/06/performance-tuning-sql-server-change-tracking/)  
I am using a query from the blog post to look to see if change tracking is enabled on my database, if auto cleanup is enabled and what the retention period for tracking changes is.

```
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
GO
SELECT
db.name AS change_tracking_db,
is_auto_cleanup_on,
retention_period,
retention_period_units_desc
FROM sys.change_tracking_databases ct
JOIN sys.databases db on
ct.database_id=db.database_id;
GO
```

<figure>

[![](/images/2019/07/sql_tracking_data_26.jpg)](blob:https://byteben.com/14052d67-6eff-4666-a128-5a8cf62ac166)

<figcaption>

is change tracking auto cleanup on?

</figcaption>

</figure>

As we can see, my SCCM database does have auto cleanup on and the retention period is 5 days! So whats going on?

The auto-cleanup should be running every 5 days...but hang on, my lab is on my laptop which is switched on intermittently - normally for testing new updates and features. Maybe i need to give the engine room more time to do its thing.

I tested a theory, totally unsupported BTW. I changed the retention period to 1 hour and went to cook dinner.

```
ALTER DATABASE CM_BB1
SET CHANGE_TRACKING (CHANGE_RETENTION = 1 Hours)
```

When i returned, the auto-cleanup had done its thing!

[![](/images/2019/07/sql_tracking_data_30-1.jpg)](blob:https://byteben.com/2920d6a4-c7c1-44a0-b55f-cc56350f6387)

I then set the retention period back to the default of 5 days

```
ALTER DATABASE CM_BB1
SET CHANGE_TRACKING (CHANGE_RETENTION = 5 days)
```

I re-ran the SCCM Update prerequisite check...

<figure>

[![](/images/2019/07/sql_tracking_data_31.jpg)](blob:https://byteben.com/936a9f31-8100-493c-8769-504f4def5962)

<figcaption>

Prerequisite passed!

</figcaption>

</figure>

### Conclusion

I don't fully understand yet why running the manual stored procedure didn't work, it just didn't handle the cleanup at all.  
**UPDATE** In SCCM 1906 the Stored Procedure spDiagChangeTracking has been updated (5.0.8853.1006) and I have been reliably informed that the SP now performs the cleanup!

Now trying the SP in 1906

<figure>

[![](/images/2019/08/sql_tracking_data_32.jpg)](blob:https://byteben.com/f432021a-8dcb-4d35-9097-0bda17033aa3)

<figcaption>

After upgrade to 1906, CT data is 6 days old

</figcaption>

</figure>

<figure>

[![](/images/2019/08/sql_tracking_data_33.jpg)](blob:https://byteben.com/f903b440-6130-4c4d-b176-b8da470247c0)

<figcaption>

After running the Stored Procedure, the tables were cleaned successfully

</figcaption>

</figure>

<figure>

[![](/images/2019/08/sql_tracking_data_34.jpg)](blob:https://byteben.com/ea2e7214-3fe0-4891-8d90-342913685320)

<figcaption>

spDiagChangeTracking changes better accounts for failed cleanups

</figcaption>

</figure>

Thanks [@GarthMJ](https://twitter.com/GarthMJ) [@SqlBenjamin](https://twitter.com/SqlBenjamin) [@AdamGrossTX](https://twitter.com/AdamGrossTX) for your help with this one.

Let me know if you have anything to add on this topic! :)