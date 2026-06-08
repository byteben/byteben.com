---
title: "Reports missing in the Configuration Manager Console"
date: 2020-10-31
categories:
  - "Certificates"
  - "ConfigMgr / MEMCM / SCCM"
  - "Microsoft"
tags: ["certificates", "configmgr", "expired-certificate", "reports-missing"]
categories: ["certificates", "configmgr-memcm-sccm", "microsoft", "uncategorized"]
---

You may have seen **No Items Found** when looking at the **Monitoring > Reporting > Reports** node in the Configuration Manager console

<!--more-->

![](/images/2020/10/image-7-1024x495.png)

> **TL;DR**
> 
> _One of the more common reasons for your reports to be missing is an expired certificate on your SQL Server Reporting Services Web Service_

If this is the case, you will have an error on the **SMS\_SRS\_REPORTING\_POINT** component. You can view the component status by: -

1. In the Configuration Manager console, go to the **Monitoring** workspace, expand **System Status**, and select the **Component Status** node
2. Select the **SMS\_SRS\_REPORTING\_POINT** component
3. On the **Home** tab of the ribbon, in the **Component** group, select **Show Messages**, and then choose **Error**
4. Specify a date and time for a period to include the time you first started noticing an issue

![](/images/2020/10/image-11.png)

Head over to your SQL Server Reporting Services Point. The server name is included in the error

Open **certlm.msc** and check for an expired certificate

![](/images/2020/10/image-12-1024x227.png)

Assuming the certificate came from your internal Certificate Authority, request a new certificate

![](/images/2020/10/image-13.png)

Verify you have a valid certificate to use on your SQL Server Reporting Services point

![](/images/2020/10/image-14.png)

Remove the expired certificate binding and assign the new certificate to the Web Service URL in **Reporting Services Configuration Manager**

![](/images/2020/10/image-20.png)

Verify your component status is reset to **OK**

![](/images/2020/10/image-16.png)

Verify the Web Service URL in **Reporting Services Configuration Manager**

![](/images/2020/10/image-18.png)

Verify Reports are now visible in the Configuration Manager Console

![](/images/2020/10/image-19-1024x464.png)

You can read more about **Reporting Services Configuration Manager** at

[https://docs.microsoft.com/en-us/sql/reporting-services/install-windows/reporting-services-configuration-manager-native-mode?view=sql-server-ver15](https://docs.microsoft.com/en-us/sql/reporting-services/install-windows/reporting-services-configuration-manager-native-mode?view=sql-server-ver15)