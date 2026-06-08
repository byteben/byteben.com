---
title: "Identifying and Updating SCCM Collection Evaluations with PowerShell"
date: 2018-12-17
categories:
  - "ConfigMgr / MEMCM / SCCM"
  - "Microsoft"
  - "Scripts"
---

I've seen this subject discussed and explained very well in other blogs. The following post is my approach and understanding on managing Collection Evaluations using a bit of PowerShell (ok so there is some SQL stuff in here too). 

<!--more-->

### Collection Evaluations

A Collection Evaluation occurs on a defined schedule, event trigger or user initiation and the membership of the Device or User Collection is re-evaluated and updated.   
  
Over time, you will have accumulated just a couple of Collections in your environment (sic). There are 5 actionable and 4 configurable options for Collection Evaluations in SCCM:-

1. No Evaluation 
2. Manual Evaluation
3. Incremental Evaluation
4. Full Evaluation
5. Both Full and Incremental Evaluation

Or put another way:-

- None
- Manual
- Periodic
- Continuous
- Both

![](/images/2018/12/image-5.png)

There are some built-in Collections that you cannot modify the Evaluation schedules on:-

- All Desktop and Server Clients
- All Custom Resources
- All Unknown Computers
- All Mobile Devices
- All Systems
- All Users
- All User Groups
- All Users and User Groups

Running the following SQL Query will show you the Update Evaluation type for each collection.

```
Select CollectionName, Flags
From dbo.v_Collections_G
Order By Flags Desc
```

The "Flags" field will return either 1,2,4 or 6 with the exception of the built-in Collections whose Evaluation Schedule cannot be modified.

<figure>

![](/images/2018/12/image-9.png)

<figcaption>

Collections whose Evaluation Schedules cannot be modified

</figcaption>

</figure>

The Flags correspond to the following Evaluation (Refresh) Types:-

<figure>

![](/images/2018/12/image-10.png)

<figcaption>

  
X = Option Selected

</figcaption>

</figure>

**NOTE:** The default Evaluation Schedule when you create a collection is "Schedule a Full Update on this Collection" - every 7 days, also known as a "Continuous" Refresh Type.

## Incremental Collection Evaluation Challenges

As per Best Practice [https://docs.microsoft.com/en-us/sccm/core/clients/manage/collections/best-practices-for-collections](https://docs.microsoft.com/en-us/sccm/core/clients/manage/collections/best-practices-for-collections) ....

> When you enable the **Use incremental updates for this collection** option, this configuration might cause evaluation delays when you enable it for many collections. The threshold is about 200 collections in your hierarchy. The exact number depends on the following factors:
> 
>   
> \- The total number of collections  
> \- The frequency of new resources being added and changed in the hierarchy  
> \- The number of clients in your hierarchy  
> \- The complexity of collection membership rules in your hierarchy

Bit vague? I'm not sure if the "200" ceiling recommendation is still valid but it's still in the official documentation so let's stick with it. How many collections do you have that are using Incremental Evaluations?

```
Select CollectionName, Flags
From dbo.v_Collections_G
Where Flags = '4'
Order By Flags Desc
```

<figure>

![](/images/2018/12/image-14.png)

<figcaption>

93 Rows Returned

</figcaption>

</figure>

93, so that's under 200 right? Well, now let's run the query to include collections that are set to Evaluate Membership with both a Full Update and Incremental Update:-

```
Select CollectionName, Flags 
From dbo.v_Collections_G
Where Flags = '4' or Flags ='6'
Order By Flags Desc
```

<figure>

![](/images/2018/12/image-13.png)

<figcaption>

353 Rows Returned

</figcaption>

</figure>

Eeek, 353. Well that sucks if we are trying to keep under 200.

Why can large numbers of Incremental Collection Evaluations be so bad? Lets do some maths. Assume we have 500 Collections that are set to Evaluate Collection membership Incrementally. By default Incremental Collection Evaluation occurs every 10 mins. So (bite lip hard and crunch math):- 
  
500 \* 144 (6 Evaluations per Hour) = 72,000 (Collection Evaluations a day) phew!

Scott Breen has an excellent article detailing Collection Evaluation, you should definitely check it out. He goes into detail on how SCCM prepares a Graph for any limiting Collections that will need re-evaluation as a result of a change in another Collection that is set to use Incremental Evaluations. Can you think of such a collection.... The built-in "All Systems" Collection actually! Read a much better explanation than mine here:- 
  
[https://blogs.technet.microsoft.com/scott/2017/09/13/collection-evaluation-overview-configuration-manager](https://blogs.technet.microsoft.com/scott/2017/09/13/collection-evaluation-overview-configuration-manager)

Incremental Collection Evaluation does have some use case scenarios, so let's demystify how they work. Take a look at some more "official" documentation here:- 
[https://msdn.microsoft.com/en-gb/library/mt629336.aspx](https://msdn.microsoft.com/en-gb/library/mt629336.aspx)  

> When you enable incremental updates for a collection, Configuration Manager periodically scans for new or changed resources from the previous collection evaluation and updates a collections membership with these resources, independently of a full collection evaluation. By default, when you enable incremental collection updates, it runs every 10 minutes and helps keep your collection data up-to-date without the overhead of a full collection evaluation.

In summary, the increased number of Incremental Collection Evaluations could have an impact on your environment, albeit they are not as resource intensive as Full Evaluations, but there will be a hit on your SQL resources. If we all had SSD SQL Servers, 200 Processor Cores and 30 Petabytes of memory for a single site server then I guess performance would never be an issue (sic)  
  
To better understand if you are having performance issues, there is a great tool in the SCCM toolkit called CEViewer (Collection Evaluation Viewer).  
  
Others have done a great job detailing the use of this tool. Head over to either of the following blogs:- 
  
[https://blogs.technet.microsoft.com/smartinez/2015/07/31/collection-evaluation-one-tool-one-report](https://blogs.technet.microsoft.com/smartinez/2015/07/31/collection-evaluation-one-tool-one-report)  
  
[https://www.anoopcnair.com/collection-evaluation-viewer](https://www.anoopcnair.com/collection-evaluation-viewer)

### Get-CMCollection

We have seen how we can get Collection Evaluation information using SQL Queries, but how do we get similar information using PowerShell?  
  
[https://docs.microsoft.com/en-us/powershell/module/configurationmanager/get-cmcollection?view=sccm-ps](https://docs.microsoft.com/en-us/powershell/module/configurationmanager/get-cmcollection?view=sccm-ps)  

**Note:** Get-CMUserCollection and Get-CMDeviceCollection were replaced with Get-CMCollection in SCCM 1601 - the commands are still valid, for now.  
  
The example below will exclude the built-in Collections that we cannot modify the Evaluation on:-

```
Get-CMCollection | Select-Object CollectionID, Name, RefreshType | Where-Object {($_.RefreshType -eq 4 -or $_.RefreshType -eq 6 )-and $_.CollectionID -NotLike "SMS*"}
```

### Set-CMCollection

If we want to change the Collection Evaluation or "Refresh Type", we can use the Set-CMCollection command.  
  
[https://docs.microsoft.com/en-us/powershell/module/configurationmanager/set-cmcollection?view=sccm-ps](https://docs.microsoft.com/en-us/powershell/module/configurationmanager/set-cmcollection?view=sccm-ps)  
  
So here is an example:-

```
Get-CMCollection -Name "Windows XP" | Set-CMCollection -RefreshType Periodic
```

The acceptable values for -RefreshType are:-

- None
- Manual
- Periodic
- Continuous
- Both

Although I would love to, I am not going to show you here an example of how to change the -RefreshType for ALL Incremental Collections. That would be too easy for someone to just visit this blog and hit "Copy - Paste" who maybe wouldn't understand the full consequences of what they are about to do.

I wasn't going to give an example of modifying multiple Collection Evaluations with PowerShell but I surrender to the masses.  
  
It could look something like this... If you were wanting to change the Evaluation Flag to Periodic for any Device Collection, excluding the inbuilt ones that are set for Incremental (Continuous) Evaluation. This is quite an inefficient way of updating the Evaluation Schedule IMO - but it does use PowerShell (point of this post) :-

```
Get-CMCollection | Select-Object CollectionID, CollectionType, RefreshType | Where-Object {$_.RefreshType -eq 4 -and $_.CollectionType -eq 2 -and $_.CollectionID -NotLike "SMS*"} | ForEach-Object {Set-CMCollection -CollectionID $_.CollectionID -RefreshType Periodic}
```

Or with a bit more filtering on Collection Name and Evaluation set to either Continuous or both Periodic and Continuous:-

```
Get-CMCollection | Select-Object CollectionID, CollectionType, Name, Comment, RefreshType | Where-Object {($_.RefreshType -eq 4 -or $_.RefreshType -eq 6 )-and $_.CollectionID -NotLike "SMS*" -and $_.Name -NotLike "*Patch*" -and $_.Name -NotLike "*Power*" -and $_.CollectionType -NotLike 1} | ForEach-Object {Set-CMCollection -CollectionID $_.CollectionID -RefreshType Periodic}
```

Important opinion in bold:-

**_Think about what you are trying to achieve if you plan to bulk update your Collection RefreshTypes._**  
  
An example of where you might want to keep Incremental Evaluations is AD Group Membership for Application Deployments. Do you really want to keep the user waiting 7 days before they get their software installed after adding them to the correct AD Group?

## Summary

So that's SCCM Collection Evaluations in a nut shell. I prefer to run my queries in SQL but we all want to do everything in PowerShell these days right?

I have enjoyed this little dirge with Collections. I am looking at creating a report that will highlight Collections with an Incremental Evaluation - keeps us sharper than pencils playing with SQL and RDL's.  
  
**UPDATE: 18/12/18** Oh Look here it is!   
  
**[All Collections (Evaluation Schedules).rdl](</downloads/All Collections \(Evaluation Schedules\).rdl>)** (Don't forget to Update your DataSource)

```
SELECT SiteID       ,LimitToCollectionID       ,CollectionName       ,CollectionComment 	  ,Flags       ,CollectionType,  Case When Flags = 1 Then 'None'  When Flags = 2 Then 'Periodic'  When Flags = 4 Then 'Continuous'  When Flags = 6 Then 'Both' End As 'Evaluation',  Case When CollectionType = 1 Then 'User'  When CollectionType = 2 Then 'Device'  End As 'CollectionType_1'  FROM dbo.v_Collections_G  Where Flags = 4 or Flags = 6 or Flags = 2 or Flags =1  Order By Flags Desc
```

  
  
Definitely have a play with the CEViewer to see if you have any issues with Collection Evaluation before you start changing the Refresh Type.

Oh, I nearly forgot (Thanks @AdamGrossTX). There was a slight bug if the Collection Evaluation was set to none (Flags=1). The Collection membership would still be evaluated on a schedule. This has been fixed in 1810 but it does require you to re-set the Collection Evaluation, more info here:- 
  
[https://docs.microsoft.com/en-us/sccm/core/plan-design/changes/whats-new-in-version-1810](https://docs.microsoft.com/en-us/sccm/core/plan-design/changes/whats-new-in-version-1810)

> Previously, when you configured a schedule on a query-based collection, the site would continue to evaluate the query whether or not you enabled the collection setting to **Schedule a full update on this collection**. To fully disable the schedule, you had to change the schedule to **None**. Now the site clears the schedule when you disable this setting. To specify a schedule for collection evaluation, enable the option to **Schedule a full update on this collection**.
> 
>