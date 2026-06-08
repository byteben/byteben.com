---
title: "Using MEMCM to fix legacy GPO settings that prevent co-managed clients getting updates from Intune"
date: 2020-07-18
categories:
  - "ConfigMgr / MEMCM / SCCM"
  - "Intune"
  - "Microsoft"
  - "Windows 10"
---

### Background

Co-management has really opened the playing field as we consider moving workloads to the cloud. I did a blog series on co-management before, check it out! [https://byteben.com/bb/co-management-series-merging-the-perimeter-part-1-what-is-co-management/](https://byteben.com/bb/co-management-series-merging-the-perimeter-part-1-what-is-co-management/)

<!--more-->

Generally speaking, as we move workloads to Intune, similar workloads are prevented from being applied to the clients from MEMCM. There are caveats to this, but I am generalising here. One of the workloads we moved recently to Intune for all company laptops was "Windows Updates". This was done during the COVID "Everyone needs to work from home now" conversation. We didn't have a CMG at the time and so we had two options. Deliver them from Intune (which was on our roadmap anyway for laptops) or configure optimal settings for the Boundary Groups for use with VPN. Moving the workload to Intune looked to be the simpler option and was our long term goal - so we went with that.

This meant adding clients to our pilot device collection for co-management in MEMCM for Windows Updates. As the clients received this policy they would then receive their Windows Update Configuration Settings from the Intune Update Ring configuration Policy - any traditional Windows Update GPO that could be in conflict with a policy delivered from Intune was blocked. We can see this on our MDM Diagnostics page:-

![](/images/2020/07/image-30-1024x477.png)

### The Problem

What did we all do back in the day with GPO and Windows Update? We set the GPO to **Disable Automatic Updates** There are lots of discussions and blogs on this particular topic, I found Jason's very interesting reading - dang, it was probably the post we read when we enabled this GPO [https://home.configmgrftw.com/software-updates-management-and-group-policy-for-configmgr-cont/](https://home.configmgrftw.com/software-updates-management-and-group-policy-for-configmgr-cont/)

I have yet to get confirmation, but it looks like there is not an equivalent CSP that gets pushed from the Intune Configuration Policy to block this GPO from applying. If the client still receives this GPO (because we used to apply that thing at the root of the domain) then Automatic Updates will be disabled! That's right - no updates..arghhh. This is what you might see on the client after you have moved the Windows Update workload to Intune:-

![](/images/2020/07/image-31.png)

and the offending registry key that causes this behaviour

<figure>

![](/images/2020/07/image-32.png)

<figcaption>

HKEY\_LOCAL\_MACHINE\\SOFTWARE\\Policies\\Microsoft\\Windows\\WindowsUpdate\\AU > NoAutoUpdate = 1

</figcaption>

</figure>

Which was created by this GPO:-

<figure>

![](/images/2020/07/image-36-1024x472.png)

<figcaption>

GPO - Computer Configuration > Administrative Templates > Windows Components > Windows Update Configure Automatic Updates

</figcaption>

</figure>

I am still playing with CSP's. If our clients are co-managed **and** we have the Device Configuration workload enabled for our clients we could deliver a CSP to block that GPO - in theory. I'll look into this more and update the blog post if the CSP works. Thanks Oliver Kieselbach for being a sounding board on my CSP thoughts [https://oliverkieselbach.com/](https://oliverkieselbach.com/)  
  
After examining the WindowsUpdate.admx template, the CSP to override that GPO setting would be:-

```
./Vendor/MSFT/Policy/Config/Update/AllowAutoUpdate
<enabled/>
<data id="AutoUpdateCfg" value="1"/>
```

![](/images/2020/07/image-33-1024x732.png)

But in this post we wont be using a CSP. In this particular environment we still needed to deliver that GPO and GPO filtering was not an option to exclude the co-managed devices from getting the registry setting that disables automatic updates.

### The Approach

This is where we see the value in using both MEMCM and Intune together. We decide to leave that GPO in place and applied a WMI filter so it only applied to servers. For the clients, we moved the GPO setting into MEMCM as a CI. We create two CI's, one to disable automatic updates for non co-managed clients and the other to enable automatic updates for co-managed clients. We can then target the baseline to the appropriate device collection.

We are using a simple registry CI for check and remediation to enable automatic updates for co-managed clients. BTW, Automatic updates are also enabled if that registry value does not exist. You could use PowerShell to remediate and delete that registry key, we are just going to change the value from 1 to 0. Lots of ways to skin a cat.

**Note**  
I won't be including high level steps on how to create Configuration Items and Baselines. Instead, I'll leave a link in the blog so you can import them into your environment to copy/paste/tweak.

### Apply a WMI Filter to the existing GPO

The GPO to **Disable Automatic Updates** was set at the root of the domain with no WMI filter. Our first job is to apply a filter so that it only applies to out of scope clients (like DC's and/or Servers). An example of what a WMI filter would like like if you only wanted it to apply to Server 2016/2019 could be:-

```
Select * from Win32_OperatingSystem WHERE (Version LIKE "10.0.%" and ProductType = "3") or (Version LIKE "10.0.%" and ProductType = "2") 
```

<figure>

![](/images/2020/07/image-35.png)

<figcaption>

Example of a WMI Filter

</figcaption>

</figure>

<figure>

![](/images/2020/07/image-34.png)

<figcaption>

WMI Filter applied to the GPO that Disables Automatic Updates

</figcaption>

</figure>

More information on creating WMI Filters for GPO's can be found here [https://docs.microsoft.com/en-us/windows/security/threat-protection/windows-firewall/create-wmi-filters-for-the-gpo](https://docs.microsoft.com/en-us/windows/security/threat-protection/windows-firewall/create-wmi-filters-for-the-gpo)

### Create the Configuration Items and Baselines

**Important** Make sure you get the timing right between applying a WMI filter on the existing GPO and your clients evaluating the new Configuration Baseline. If you apply the WMI filter BEFORE your clients evaluate the Configuration Baseline those client may get automatic updates enabled because the GPO applies before the CI is evaluated - very undesirable.

The baselines can be downloaded here:-

[/downloads/Enable%20Automatic%20Updates.cab](/downloads/Enable%20Automatic%20Updates.cab)  
[/downloads/Disable%20Automatic%20Updates.cab](/downloads/Disable%20Automatic%20Updates.cab)

**Enable Automatic Updates CI/CB**

The **Enable Automatic Updates** Configuration Baseline, when deployed, will evaluate the following registry value **HKEY\_LOCAL\_MACHINE\\SOFTWARE\\Policies\\Microsoft\\Windows\\WindowsUpdate\\AU > NoAutoUpdate**  
  
The CI is set to remediate any value that is not 0.

**Disable Automatic Updates CI/CB**

The **Disable Automatic Updates** Configuration Baseline, when deployed, will evaluate the following registry value **HKEY\_LOCAL\_MACHINE\\SOFTWARE\\Policies\\Microsoft\\Windows\\WindowsUpdate\\AU > NoAutoUpdate**

The CI is set to remediate any value that is not 1.

#### Import configuration data

1. In the Configuration Manager console, click **Assets and Compliance** > **Configuration Baselines**
2. In the **Home** tab, in the **Create** group, click **Import Configuration Data**.
3. On the **Select Files** page of the **Import Configuration Data Wizard**, click **Add**, and then in the **Open** dialog box, select the .cab files you want to import.
4. Select the **Create a new copy of the imported configuration baselines and configuration items** check box if you want the imported configuration data to be editable in the Configuration Manager console.
5. On the **Summary** page, review the actions that will be taken, and then complete the wizard.

Source: [https://docs.microsoft.com/en-us/mem/configmgr/compliance/deploy-use/import-configuration-data](https://docs.microsoft.com/en-us/mem/configmgr/compliance/deploy-use/import-configuration-data)

**Note**

- The Cab files contain both the Baselines and associated CI's
- I have not signed the CAB files so you will be prompted to accept that security risk
- The CABs are exported from CB 2002

![](/images/2020/07/image-38-1024x905.png)

#### Deploy the Configuration Baselines

You will need the collection that identifies the clients that have had the **Windows Updates** workload moved to Intune. In this environment, it looks like below:-

![](/images/2020/07/image-40.png)

![](/images/2020/07/image-41.png)

Deploy the **Enable Automatic Updates** Configuration Baseline to your Co-Management "Windows Update" Pilot Collection

![](/images/2020/07/image-43.png)

Deploy the **Disable Automatic Updates** to a Device Collection that includes all clients in scope but **Excludes** your Co-Management "Windows Update" Pilot Collection

![](/images/2020/07/image-44.png)

When deploying either Configuration Baseline, ensure you select **remediate noncompliant rules when supported**

![](/images/2020/07/image-39-1024x618.png)

### Results

With the Configuration Baseline **Disable Automatic Updates** deployed, your Windows Update Settings will look like this (Note: "Your organization has turned off automatic updates")

![](/images/2020/07/image-46.png)

With the Configuration Baseline **Enable Automatic Updates** deployed, your Windows Update Settings will look like this (Note: "Your organization has turned off automatic updates" has gone)

![](/images/2020/07/image-45.png)

### Summary

In this post we identified that a legacy GPO could be blocking automatic updates when we move our Windows Update workload to Intune for co-managed clients. We applied a WMI filter to exclude the clients from receiving the GPO but left the GPO in place for Domain Members who patch outside of MEMCM e.g. Domain Controllers. Next, we created some Configuration Items to Enable and Disable Automatic Updates and deployed the Configuration Baselines to the appropriate collections. Finally, we observed the co-managed clients receiving updates from Intune after we enabled Automatic Updates.

As I said at the beginning of the post, you could find another way to remove the registry value that disables automatic updates. I will be investigating whether I can do this with a CSP. If I can this will work well for co-managed clients who also have their workload move to Intune for Device Configuration.

**\*\*Update\*\* 22/07/20**

Thanks to Per Larsen for reminding me of a cool feature that is currently in preview.

**Endpoint Analytics Proactive Remediation**

Think of it like your traditional CI in MEMCM. You can run scripts on a schedule, from Intune, to remediate clients. Ill delve more into Proactive Remediations later but I actually managed to re-enable automatic updates using the two scripts below. Its pretty cool stuff! Read more here [https://docs.microsoft.com/en-us/mem/analytics/proactive-remediations](https://docs.microsoft.com/en-us/mem/analytics/proactive-remediations)

[https://github.com/byteben/Windows-10/blob/master/EnableAutomaticUpdates.ps1](https://github.com/byteben/Windows-10/blob/master/EnableAutomaticUpdates.ps1)  
[https://github.com/byteben/Windows-10/blob/master/Detect\_EnableAutomaticUpdates.ps1](https://github.com/byteben/Windows-10/blob/master/Detect_EnableAutomaticUpdates.ps1)

Granted, I managed to address the issue using CI's but I did manage to catch a few that had not evaluated my baseline yet

![](/images/2020/07/image-48-1024x496.png)