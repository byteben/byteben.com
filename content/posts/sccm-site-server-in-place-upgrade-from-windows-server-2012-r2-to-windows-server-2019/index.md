---
title: "SCCM Site Server In-Place Upgrade from Windows Server 2012 R2 to Windows Server 2019"
date: 2019-07-07
categories:
  - "ConfigMgr / MEMCM / SCCM"
  - "Microsoft"
tags: ["configmgr", "in-place-upgrade", "ipu", "primary-site-server", "sccm", "server-2012-r2", "server-2019", "site-reset"]
---

I am rationalizing and updating my lab on a grey, Saturday afternoon and decided to blog the update process for getting my Server 2012 R2 Primary Site Server up to Server 2019. 
SQL Server is not installed on the same VM in my lab. You should make other considerations if SQL is installed on your Site Server - these are not covered in this post.

<!--more-->

<figure>

[![](/images/2019/07/sccm_upgrade_5.jpg)](blob:https://byteben.com/6747e33e-2863-4d06-bf05-4098aebf41a4)

<figcaption>

My lab Primary Site Server on Server 2012 R2

</figcaption>

</figure>

This post will cover the following areas when upgrading the Site Server OS:-

1. [OS Prerequisites](#1)
2. [SCCM Prerequisites](#2)
3. [OS Upgrade](#3)
4. [Post Upgrade OS Tasks](#4)
5. [Post Upgrade SCCM Tasks](#5)

### 1\. OS Prerequisites **[⏏](#NavMenu)**

I would recommend practicing an In-Place-Upgrade from Server 2012 R2 to Server 2019 in your lab, on a "normal" server, before attempting it on your Primary Site Server. More information on upgrading the OS can be found in the following doc:-

[https://docs.microsoft.com/en-us/windows-server/get-started/supported-upgrade-paths](https://docs.microsoft.com/en-us/windows-server/get-started/supported-upgrade-paths)

The items below are some of the more common gotcha's to check for:-

1. Disable NIC Teaming before upgrading the OS and then re-enable it after the upgrade is complete [https://docs.microsoft.com/en-us/previous-versions/windows/it-pro/windows-server-2012-R2-and-2012/hh831648(v=ws.11)](https://docs.microsoft.com/en-us/previous-versions/windows/it-pro/windows-server-2012-R2-and-2012/hh831648\(v=ws.11\))
2. 32GB Minimum space on the OS drive
3. It is recommended to install the latest Windows updates for Server 2012 R2 before beginning an In-Place-Upgrade  
    [https://www.microsoft.com/upgradecenter/scenario/WS2012R2-on-prem-to-WS2019](https://www.microsoft.com/upgradecenter/scenario/WS2012R2-on-prem-to-WS2019)
4. Windows Servers configured to “Boot from VHD” cannot be upgraded using In-place Upgrade  
    [https://www.microsoft.com/upgradecenter/scenario/WS2012R2-on-prem-to-WS2019](https://www.microsoft.com/upgradecenter/scenario/WS2012R2-on-prem-to-WS2019)

### 2\. SCCM Prerequisites **[⏏](#NavMenu)**

Here are the prerequisites required by SCCM before you attempt an In-Place-Upgrade on your Site Server:- 
  
**Source:** [https://docs.microsoft.com/en-us/sccm/core/plan-design/configs/supported-operating-systems-for-site-system-servers](https://docs.microsoft.com/en-us/sccm/core/plan-design/configs/supported-operating-systems-for-site-system-servers)

1. This is a good time to re-evaluate the hardware requirements for your Site Server  
    [https://docs.microsoft.com/en-us/sccm/core/plan-design/configs/supported-operating-systems-for-site-system-servers](https://docs.microsoft.com/en-us/sccm/core/plan-design/configs/supported-operating-systems-for-site-system-servers)
2. You must be on SCCM CB 1810  
    [https://docs.microsoft.com/en-us/sccm/core/plan-design/configs/supported-operating-systems-for-site-system-servers#bkmk\_2019](https://docs.microsoft.com/en-us/sccm/core/plan-design/configs/supported-operating-systems-for-site-system-servers#bkmk_2019)
3. Remove the SCEP client if you have it installed (Windows defender is built-in to Server 2019)  
    [https://docs.microsoft.com/en-us/sccm/core/servers/manage/upgrade-on-premises-infrastructure#before-upgrade](https://docs.microsoft.com/en-us/sccm/core/servers/manage/upgrade-on-premises-infrastructure#before-upgrade)
4. Remove - WSUS? Microsoft still say you need to do this. This was certainly necessary when upgrading from Server 2008 R2 to Server 2012 R2 (WSUS 3 > 4) - the upgrade wizard would hard block the upgrade if you didn't. In my testing, WSUS 4 (Server 2012 R2) upgrades fine to WSUS 10 (Server 2016/2019) with no hard block. I have a pull request with Microsoft Docs to see if this statement is still true.  
    [https://docs.microsoft.com/en-us/sccm/core/servers/manage/upgrade-on-premises-infrastructure#before-upgrade](https://docs.microsoft.com/en-us/sccm/core/servers/manage/upgrade-on-premises-infrastructure#before-upgrade)
5. Ensure you have an up to date Site Backup (better to have one and not need it)  
    [https://docs.microsoft.com/en-us/sccm/core/servers/manage/backup-and-recovery](https://docs.microsoft.com/en-us/sccm/core/servers/manage/backup-and-recovery)
6. Ensure you have a healthy Site Server. Check the Component Status in **Monitoring > System Status > Site Status / Component Status**

### 3\. OS Upgrade **[⏏](#NavMenu)**[](#NavMenu)

1 . Insert your media

2 . Launch Setup.exe

3 . Select the following:- 
  
**Download updates, drivers and option feature (recommended)**  
**I want to help make this installation of Windows better** - We all want to help right!?  
  
Click **Next**

<figure>

[![](/images/2019/07/sccm_upgrade_1.jpg)](blob:https://byteben.com/f11f5b45-d7e7-4d02-a3b2-1534e2409d92)

<figcaption>

Select the following options (option 2 at your discretion)

</figcaption>

</figure>

4 . Choose the Edition you wish to upgrade to and click **Next**

\* Core editions are only supported for the Distribution Point role

<figure>

[![](/images/2019/07/sccm_upgrade_2.jpg)](blob:https://byteben.com/13fd76b7-af2e-4ab6-b585-307ea4f039b8)

<figcaption>

Core installations are only supported for the Distribution Point role

</figcaption>

</figure>

5 . Accept the License Terms

6 . Choose to **Keep personal files and apps** and click **Next**

<figure>

![](/images/2019/07/sccm_upgrade_3.jpg)

<figcaption>

Choose what to keep and click **Next**

</figcaption>

</figure>

7 . Once the setup process has completed validation, click **Install**

<figure>

![](/images/2019/07/sccm_upgrade_4.jpg)

<figcaption>

Click Install

</figcaption>

</figure>

8 . Sit back and wait

<figure>

[![](/images/2019/07/sccm_upgrade_6.jpg)](/images/2019/07/sccm_upgrade_6.jpg)

<figcaption>

Wait....

</figcaption>

</figure>

9 . Your Server will restart several times

<figure>

[![](/images/2019/07/sccm_upgrade_7.jpg)](blob:https://byteben.com/fce1129f-66d0-4f6a-90c6-8f5ed3a8df76)

<figcaption>

Your Server will restart several times

</figcaption>

</figure>

10 . Login to the server post OS upgrade

[![](/images/2019/07/sccm_upgrade_9.jpg)](blob:https://byteben.com/ca808cdf-2506-4015-b077-e342b7d93d97)

### 4\. Post Upgrade OS Tasks **[⏏](#NavMenu)**

The operating system has upgraded successfully - here is what we need to do/check next

1 . Check IIS is running

<figure>

[![](/images/2019/07/sccm_upgrade_28-1024x656.jpg)](blob:https://byteben.com/993da20a-6659-4a78-8997-fe61c13bd258)

<figcaption>

Check IIS is running

</figcaption>

</figure>

2 . Check the WSUS Service is running

<figure>

[![](/images/2019/07/sccm_upgrade_12.jpg)](blob:https://byteben.com/cd423911-c348-4242-90c2-85c7ec5e0148)

<figcaption>

Check the WSUS Service is running

</figcaption>

</figure>

3 . Complete the WSUS Configuration Wizard  
  
i . Launch the WSUS Console  
ii . Click **Run**

<figure>

[![](/images/2019/07/sccm_upgrade_11.jpg)](/images/2019/07/sccm_upgrade_11.jpg)

<figcaption>

Click **Run**

</figcaption>

</figure>

iii . Click **Close**

<figure>

[![](/images/2019/07/sccm_upgrade_13.jpg)](/images/2019/07/sccm_upgrade_13.jpg)

<figcaption>

Click **Close**

</figcaption>

</figure>

4 . Activate Windows with a valid Product Key

[![](/images/2019/07/sccm_upgrade_14.jpg)](/images/2019/07/sccm_upgrade_14.jpg)

5 . Check the Windows Defender Antivirus Service/s have started

<figure>

[![](/images/2019/07/sccm_upgrade_15.jpg)](/images/2019/07/sccm_upgrade_15.jpg)

<figcaption>

Check the Windows Defender Antivirus Service/s have started

</figcaption>

</figure>

**TIP:** Some prerequisites configured above may have prevented some SCCM services from starting. It is recommended to reboot before proceeding to the next section

### 5\. Post Upgrade SCCM Tasks **[⏏](https://byteben.com/bb/wp-admin/post.php?post=2030&action=edit#NavMenu)**

The operating system has been upgraded and the Windows Services required by SCCM have been checked/configured. Here is what we need to check/configure in SCCM as per:-

[https://docs.microsoft.com/en-us/sccm/core/servers/manage/upgrade-on-premises-infrastructure#after-upgrade](https://docs.microsoft.com/en-us/sccm/core/servers/manage/upgrade-on-premises-infrastructure#after-upgrade)

1 . Make sure the following Configuration Manager services are running:-

- SMS\_EXECUTIVE
- SMS\_SITE\_COMPONENT\_MANAGER

<figure>

[![](/images/2019/07/sccm_upgrade_16.jpg)](/images/2019/07/sccm_upgrade_16.jpg)

<figcaption>

Make sure the following Configuration Manager services are running

</figcaption>

</figure>

2 . Make sure the **Windows Process Activation** and **WWW/W3svc** services are enabled and set for automatic start. The upgrade process can disable these services (not observed in my lab)

<figure>

[![](/images/2019/07/sccm_upgrade_17.jpg)](/images/2019/07/sccm_upgrade_17.jpg)

<figcaption>

Make sure the Windows Process Activation and WWW Services are running

</figcaption>

</figure>

3 . Perform a Site Reset if this is a Primary Site Server. The site reset will:-

- Reapply the default Configuration Manager file and registry permissions
- Re-install all site components and all site system roles at the site

For more information on performing a Site Reset, visit:- 
  
[https://docs.microsoft.com/en-us/sccm/core/servers/manage/modify-your-infrastructure#bkmk\_reset](https://docs.microsoft.com/en-us/sccm/core/servers/manage/modify-your-infrastructure#bkmk_reset)  
  
i . Run **Configuration Manager Setup** from **<Configuration Manager site installation folder>\\BIN\\X64\\setup.exe** \*  
  
**\*** You must be logged on as a Full Administrator to perform a site reset

<figure>

[![](/images/2019/07/sccm_upgrade_18.jpg)](/images/2019/07/sccm_upgrade_18.jpg)

<figcaption>

Run setup.exe from the installation folder

</figcaption>

</figure>

ii . Click **Next**

<figure>

[![](/images/2019/07/sccm_upgrade_19.jpg)](/images/2019/07/sccm_upgrade_19.jpg)

<figcaption>

Click **Next**

</figcaption>

</figure>

iii . Ensure **Perform site maintenance or reset this site** is selected and click **Next**

<figure>

[![](/images/2019/07/sccm_upgrade_20.jpg)](/images/2019/07/sccm_upgrade_20.jpg)

<figcaption>

Select **Perform site maintenance or reset this site** and click **Next**

</figcaption>

</figure>

iv . Ensure **Reset site with no configuration changes** is selected and click **Next**

<figure>

[![](/images/2019/07/sccm_upgrade_21.jpg)](blob:https://byteben.com/dd0d4158-39ac-4453-bc8a-7cd33668e8fc)

<figcaption>

Ensure **Reset site with no configuration changes** is selected and click **Next**

</figcaption>

</figure>

v . Click **Yes**

<figure>

[![](/images/2019/07/sccm_upgrade_22.jpg)](/images/2019/07/sccm_upgrade_22.jpg)

<figcaption>

Click **Yes**

</figcaption>

</figure>

vi . Review **ConfigMgrSetup.log** for a successful/ site reset

<figure>

[![](/images/2019/07/sccm_upgrade_23.jpg)](/images/2019/07/sccm_upgrade_23.jpg)

<figcaption>

Site Reset Successful

</figcaption>

</figure>

<figure>

![](/images/2019/07/sccm_upgrade_24.jpg)

<figcaption>

ConfigMgrSetup.log

</figcaption>

</figure>

4 . Officially, you should review the following Microsoft Document to ensure all your Prerequisites are still met. "For example, you might need to reinstall BITS, WSUS, or configure specific settings for IIS". I didn't need to do this in my lab.

[https://docs.microsoft.com/en-us/sccm/core/plan-design/configs/site-and-site-system-prerequisites](https://docs.microsoft.com/en-us/sccm/core/plan-design/configs/site-and-site-system-prerequisites)

5\. Reboot the server

**TIP:** Don't be tempted to "fix" components too soon. Let the Component Service do its thing and settle down before panic mode sets in.

### Summary

So the upgrade was fairly painless in my lab.

For **Known Issues** when performing an In-Place-Upgrade on a Site Server, refer to the following Microsoft Document:-

[https://docs.microsoft.com/en-us/sccm/core/servers/manage/upgrade-on-premises-infrastructure#known-issue-for-remote-configuration-manager-consoles](https://docs.microsoft.com/en-us/sccm/core/servers/manage/upgrade-on-premises-infrastructure#known-issue-for-remote-configuration-manager-consoles)

The In-Place-Upgrade is supported in Production for SCCM 1810 but I would strongly urge you to test this in your lab first. All things considered, it was a fairly simple process.

I am now off to switch on and test LEDBAT :)

<figure>

[![](/images/2019/07/sccm_upgrade_27.jpg)](blob:https://byteben.com/cef5501a-0d18-408f-a894-054bb3e52ea6)

<figcaption>

Successful Upgrade :)

</figcaption>

</figure>