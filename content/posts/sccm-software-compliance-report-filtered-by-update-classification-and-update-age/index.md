---
title: "SCCM Software Compliance Report Filtered by Update Classification and Update Age"
date: 2018-12-15
categories:
  - "ConfigMgr / MEMCM / SCCM"
  - "Microsoft"
---

This SSRS Report has been sitting in the side lines for a while now. After spending a bit more time on it over the weekend I feel it is now at a point where it is serving me rather than the other way around.

<!--more-->

Our teams wanted to know how many updates were outstanding for each client, how old the updates were and what the Update Classification was.

The real show stopper was trying to get Update Classification into the report. After finding the correct SQL view things started to fall into place.

![](/images/2018/12/image.png)

```
SELECT 
CategoryInstanceID, 
CategoryInstanceName 

FROM 
v_CategoryInfo

WHERE 
CategoryTypeName = 'UpdateClassification'
```

Gives the following results:-

16777242 Applications  
16777243 Critical Updates  
16777244 Definition Updates  
16777245 Drivers  
16777246 Feature Packs  
16777247 Security Updates  
16777248 Service Packs  
16777249 Tools  
16777250 Update Rollups  
16777251 Updates  
16777252 WSUS Infrastructure Updates  
16777466 Upgrades

So we could take this knowledge, and use CategoryInstanceID to filter Update Classifications - cool.

Cutting a long story short, and just putting this post together quickly because i promised to share the query, here it is in SQL Query format.

Modify @COLLID to the collection you want to test against. @COLLID is a parameter in our SSRS Report. We are only setting the variable here so we can return some results in SQL

> Set @COLLID = 'SMS00001'
> 
> Modify @COLLID value in your SQL Query

[![](/images/2018/12/image-2-1024x534.png)](/images/2018/12/image-2.png)

```
Declare @COLLID VARCHAR(50)
Declare @StartDate30 As Date
Declare @EndDate31 As Date
Declare @StartDate60 As Date
Declare @EndDate0 As Date
Declare @EndDate61 As Date
Declare @StartDateOlder As Date
Declare @EndDate As Date
Declare @StartDate As Date
Declare @EndDate81 As Date
Declare @StartDate80 As Date

Set @StartDate30 = DateAdd("d",-30,GETDATE())
Set @EndDate31 = DateAdd("d",-31,GETDATE())
Set @StartDate60 = DateAdd("d",-60,GETDATE())
Set @EndDate0 = GETDATE()
Set @EndDate61 = DateAdd("d",-61,GETDATE())
Set @StartDateOlder = DateAdd("d",-3650,GETDATE())
Set @EndDate = GETDATE()
Set @StartDate = DateAdd("d",-3650,GETDATE())
Set @EndDate81 = DateAdd("d",-81,GETDATE())
Set @StartDate80 = DateAdd("d",-80,GETDATE())

Set @COLLID = 'SMS00001'

select
            CS.Name0,CS.UserName0,CS.Domain0,CS.ResourceID,
      FCM.collectionID,
	  os.caption0 [OS],
CONVERT(VARCHAR(26), uss.lastscantime, 100) AS 'Last Su Scan',
IP.IPAddress AS [IP Address],

Case when sum(case when bl.clientstate >=1 then 1 else 0 end) > 0 then '*' end as 'Restart Required',

case
when (sum(case when UCS.status=2 then 1 else 0 end))>0 then ((cast(sum(case when UCS.status=2 then 1 else 0 end)as INT)))
else '0'
end as 'Patch Status',

case
when (sum(case when UCS.status=2 and ui.DateRevised>=@StartDate30 and ui.DateRevised<@EndDate0 then 1 else 0 end))>0 then ((cast(sum(case when UCS.status=2 and ui.DateRevised>=@StartDate30 and ui.DateRevised<@EndDate0 then 1 else 0 end)as INT)))
else '0'
end as '0 to 30',

case
when (sum(case when UCS.status=2 and ui.DateRevised>=@StartDate60 and ui.DateRevised<@EndDate31 then 1 else 0 end))>0 then ((cast(sum(case when UCS.status=2 and ui.DateRevised>=@StartDate60 and ui.DateRevised<@EndDate31 then 1 else 0 end)as INT)))
else '0'
end as '31 to 60',

case
when (sum(case when UCS.status=2 and ui.DateRevised>=@StartDate80 and ui.DateRevised<@EndDate61 then 1 else 0 end))>0 then ((cast(sum(case when UCS.status=2 and ui.DateRevised>=@StartDate80 and ui.DateRevised<@EndDate61 then 1 else 0 end)as INT)))
else '0'
end as '61 to 80',

case
when (sum(case when UCS.status=2 and ui.DateRevised>=@StartDateOlder and ui.DateRevised<@EndDate81 then 1 else 0 end))>0 then ((cast(sum(case when UCS.status=2 and ui.DateRevised>=@StartDateOlder and ui.DateRevised<@EndDate81 then 1 else 0 end)as INT)))
else '0'
end as '81 plus',

case
when (sum(case when UCS.status=2 and catinfo2.CategoryInstanceID = '16777243' then 1 else 0 end))>0 then ((cast(sum(case when UCS.status=2 and catinfo2.CategoryInstanceID = '16777243' then 1 else 0 end)as INT)))
else '0'
end as 'Critical',

case
when (sum(case when UCS.status=2 and catinfo2.CategoryInstanceID = '16777247' then 1 else 0 end))>0 then ((cast(sum(case when UCS.status=2 and catinfo2.CategoryInstanceID = '16777247' then 1 else 0 end)as INT)))
else '0'
end as 'Security',

case
when (sum(case when UCS.status=2 and catinfo2.CategoryInstanceID = '16777248' then 1 else 0 end))>0 then ((cast(sum(case when UCS.status=2 and catinfo2.CategoryInstanceID = '16777248' then 1 else 0 end)as INT)))
else '0'
end as 'Service Pack',

case
when (sum(case when UCS.status=2 and catinfo2.CategoryInstanceID = '16777250' then 1 else 0 end))>0 then ((cast(sum(case when UCS.status=2 and catinfo2.CategoryInstanceID = '16777250' then 1 else 0 end)as INT)))
else '0'
end as 'Rollup'

from
      v_UpdateComplianceStatus UCS
left outer join dbo.v_GS_COMPUTER_SYSTEM  CS on CS.ResourceID = UCS.ResourceID
join v_CICategories_All catall2 on catall2.CI_ID=UCS.CI_ID
join v_CategoryInfo catinfo2 on catall2.CategoryInstance_UniqueID = catinfo2.CategoryInstance_UniqueID and catinfo2.CategoryTypeName='UpdateClassification'
left join v_gs_workstation_status ws on ws.resourceid=CS.resourceid
left join v_fullcollectionmembership FCM on FCM.resourceid=CS.resourceid

left join v_CombinedDeviceResources bl on bl.MachineID=ucs.resourceid

inner join v_UpdateInfo ui on ui.CI_ID=ucs.CI_ID
left join v_GS_OPERATING_SYSTEM OS on os.ResourceID=ucs.ResourceID
left join v_UpdateScanStatus USS on uss.ResourceID=ucs.ResourceID
left JOIN (SELECT	 IP1.resourceid AS rsid2, IPAddress = substring
				((SELECT	 (IP_Addresses0 + ', ')
				FROM	v_RA_System_IPAddresses IP2
				WHERE	 IP2.IP_Addresses0 NOT LIKE '169%' AND IP2.IP_Addresses0 NOT LIKE '0.%' AND IP2.IP_Addresses0 NOT LIKE '%::%' AND
				IP_Addresses0 NOT LIKE '192.%' AND IP1.resourceid = IP2.resourceid
				ORDER BY resourceid FOR xml path('')), 1, 50000)
				FROM	v_RA_System_IPAddresses IP1
				GROUP BY resourceid) IP ON IP.rsid2 = ucs.resourceid

Where FCM.collectionid = @COLLID
and ui.IsExpired=0 and ui.IsSuperseded=0

/*
######
Update Classifications
Modify and clause below to filter include only * Update Classifications
16777242	Applications
*16777243	Critical Updates
16777244	Definition Updates
16777245	Drivers
16777246	Feature Packs
*16777247	Security Updates
*16777248	Service Packs
16777249	Tools
*16777250	Update Rollups
16777251	Updates
16777252	WSUS Infrastructure Updates
16777466	Upgrades
######
*/

and (catinfo2.CategoryInstanceID = '16777243' 
or catinfo2.CategoryInstanceID = '16777247' 
or catinfo2.CategoryInstanceID = '16777248' 
or catinfo2.CategoryInstanceID = '16777250')

Group by CS.Name0,CS.UserName0,CS.Domain0,CS.ResourceID,FCM.collectionID,os.Caption0,uss.lastscantime,[IPAddress],OS.LastBootUpTime0
Order by CS.Name0,CS.UserName0,CS.Domain0,CS.ResourceID,FCM.collectionID,os.Caption0,uss.lastscantime,[IPAddress],OS.LastBootUpTime0
```

The RDL for SSRS is below for you your convenience. Remember to update the DataSource and modify the @COLLID Parameter to modify the Collections available to the report.

[![](http://byteben.com/bb/images/2018/12/Update_Classification_SSRS-1024x496.jpg)](/images/2018/12/Update_Classification_SSRS.jpg)

Download Here   
**[Compliance 12 - Patches Required for Collection\_121120\_Public.rdl](<https://byteben.com/bb/Downloads/Compliance 12 - Patches Required for Collection_121120_Public.rdl>)**

**\*UPDATE\* 12/11/2020 - RDL updated to remove invalid link to custom Drill through report.**  
Please remember to select your own data source after uploading the RDL to your Report Server  
You will also need to edit the RDL with a text editor and replace **ConfigMgr\_SS1** with **ConfigMgr\_XXX where XXX** is your Site Code

![](/images/2020/11/image.png)

Had help from a few folks on this along the way:-

- Eswar has great examples of SSRS reports on his blog [http://eskonr.com/](http://eskonr.com/)
- Adam Gross is just a selfless SCCM Ninja who I respect greatly. When i just about gave up with Case SQL Statements he jumped in and helped out [https://www.asquaredozen.com/](https://www.asquaredozen.com/)
- Garth Jones for writing an invaluable book on SSRS and lending an Olive Branch [http://www.enhansoft.com/blog/author/garth/page/13](http://www.enhansoft.com/blog/author/garth/page/13)
- Chris Buck for being super nice and offering help [https://sccmf12twice.com](https://sccmf12twice.com/)