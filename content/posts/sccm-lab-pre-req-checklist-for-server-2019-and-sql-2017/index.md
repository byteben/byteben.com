---
title: "SCCM Lab Pre-Req Checklist for Server 2019 and SQL 2017"
date: 2019-02-10
categories:
  - "ConfigMgr / MEMCM / SCCM"
  - "Microsoft"
tags: ["configmgr", "server-2019", "technical-preview"]
---

I decided to rebuild one of my LABs for SCCM 1902 Technical Preview. During the build, someone posed a question on Twitter for examples of scripts/material to get a LAB up and running. @ncbrady has a great post that goes into great detail for building out SCCM servers at:-

<!--more-->

[https://www.windows-noob.com/forums/topic/16114-how-can-i-install-system-center-configuration-manager-current-branch-version-1802-on-windows-server-2016-with-sql-server-2017-part-1/](https://www.windows-noob.com/forums/topic/16114-how-can-i-install-system-center-configuration-manager-current-branch-version-1802-on-windows-server-2016-with-sql-server-2017-part-1/)

My post doesn't go into that amount of detail, it is just a simple checklist for me when building out my TP lab and I thought I'd share the love. I'll refer to this post for my future "Nuke the LAB from Orbit" projects.

For the TP Infrastructure I keep things quite simple with two servers:-

- Domain Controller: Hosting AD/DHCP/DNS/CertSrv
    
- ConfigMgr Server: Hosting SCCM/WSUS/SQL/SSRS.
- Did I say only 2 servers? I have a RRAS giving Internet connectivity for all my labs so I'll give it a mention.

This post makes lots of assumptions e.g you know how to spin up a working Server 2019 VM in Hyper-V and have installed and configured the necessary roles to get your AD/DNS/DHCP services working.

It doesn't cover detailed specs for hardware. I'm running my labs on a Dell XPS15. I quickly create a VM, attach the Server 2019 ISO, leave all the default Hyper-V settings and spin her up. I don't scale out my labs (because I'm poor) and don't really expect to hit any performance issues with my 2-3 test clients.

For my TP lab I do not follow best practice on disk layout or sizing for SQL or SCCM (slaps back of own hand). Everything goes on the C drive - do not do this in production..never..hear me! For the official sizing guides, visit:-

[https://docs.microsoft.com/en-us/sccm/core/plan-design/configs/recommended-hardware](https://docs.microsoft.com/en-us/sccm/core/plan-design/configs/recommended-hardware)

[https://docs.microsoft.com/en-us/sccm/core/plan-design/hierarchy/plan-for-the-site-database](https://docs.microsoft.com/en-us/sccm/core/plan-design/hierarchy/plan-for-the-site-database)

So this really is a "What do I need to do to BEFORE I install a shiny Primary Site Server in my lab" post.

### **On Lab Domain Controller**

1 . Make sure the domain account you use during setup is a Domain Admin and a Schema Admin

2 . Using ADSI Edit, Create "System Management" Container on DC

- Expand Domain
- Right-click CN=System
- Click New - Object
- Select Container, and then click Next.
- In the value box, type "System Management"
- Assign SiteServer$ Computer Account Full Permissions for this object and all descendant objects

3 . Extend AD Schema  
SMSSETUP\\BIN\\X64\\extadsh.exe

4 . Create SQL Services Accounts  
domain\\SQLAgent  
domain\\SQLService  
domain\\SQLReport

### **On Lab Primary**

1 . Download and Install SQL Server 2017 (with cumulative update 2 or later) from VLSC/Visual Studio or Trial (below)  
[https://www.microsoft.com/en-gb/sql-server/sql-server-downloads#](<https://www.microsoft.com/en-gb/sql-server/sql-server-downloads# >)  

**_!IMPORTANT!_** Set Default Collation to "SQL\_Latin1\_General\_CP1\_CI\_AS" during SQL configuration.

2 . Configure SQL Server Memory Usage Maximum Limit

3 . Configure SQL Server Min Memory to 8GB (or less if poor like me)

4 . Configure SQL Server Security Authentication to Windows Mode Only

5 . Download and Install SSRS 2017  
[https://www.microsoft.com/en-us/download/details.aspx?id=55252](https://www.microsoft.com/en-us/download/details.aspx?id=55252)

6 . Configure SSRS Service account as domain\\SQLReport

7 . Download and Install SSMS 17 SQL Mgmt Studio  
[https://go.microsoft.com/fwlink/?linkid=2043154](https://go.microsoft.com/fwlink/?linkid=2043154)  

8 . Download and Install Windows 10 1809 ADK  
[https://go.microsoft.com/fwlink/?linkid=2026036](https://go.microsoft.com/fwlink/?linkid=2026036)  
  
Select the following features:-

- Deployment Tools
- User State Migration Tool (USMT)

9 . Download and Install Windows 10 1809 WinPE Add-On  
[https://go.microsoft.com/fwlink/?linkid=2022233](https://go.microsoft.com/fwlink/?linkid=2022233)

10 . Download ConfigMgr CB TP Baseline Media  
[https://www.microsoft.com/evalcenter/evaluate-system-center-configuration-manager-and-endpoint-protection-technical-preview](https://www.microsoft.com/evalcenter/evaluate-system-center-configuration-manager-and-endpoint-protection-technical-preview)

11 . Install Windows Features:-

**Windows Server Update Services** (accept additional features)

- Un-Select WID Connectivity
- Select SQL Server Connectivity
- Select WSUS Services
- Set WSUS Content Path e.g. C:\\WSUS
- Specify WSUS DB Instance to "LOCALHOST"

**IIS configuration** (Select the following):-

**Common HTTP Features:**  
Default Document  
Static Content

**Security:**  
Windows Authentication

**Application Development:**  
ASP.NET 3.5 (accept additional features)  
.NET Extensibility 3.5  
ASP.NET 4.7 (accept additional features)  
.NET Extensibility 4.5  
ISAPI Extensions

**IIS 6 Management Compatibility:**  
IIS 6 Metabase Compatibility  
IIS 6 WMI Compatibility

**.NET Framework 3.5 Features**  
.NET Framework 3.5 (includes .NET 2.0 and 3.0)

**.NET Framework 4.7 Features**  
.NET Framework 4.7 (installed by default in OS)  
HTTP Activation (and automatically selected options)

**BITS Server Extensions** (accept additional features)

**Remote Differential Compression**

12 . Complete WSUS Post Installation Tasks from Server Manager

13 . Run the ConfigMgr Pre Requisite Check tool:- 
MEDIA\\SMSSETUP\\BIN\\X64\\prereqchk.exe /local

**Install ConfigMgr**

Check/Re-mediate TLS1.2 support for SQL Native Client 2012  
[https://www.microsoft.com/en-us/download/details.aspx?id=56041](https://www.microsoft.com/en-us/download/details.aspx?id=56041)  
ENU\\x64\\sqlncli.msi (4.8MB) - Smaller than downloading the Full SQL Service Pack 4 (1GB)

**Install ConfigMgr**