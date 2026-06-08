---
title: "Deploy Windows 10 Desktop Shortcuts and Icons with SCCM Configuration Baselines"
date: 2019-05-12
categories:
  - "ConfigMgr / MEMCM / SCCM"
  - "Microsoft"
  - "Windows 10"
tags: ["ico", "applications", "baseline-evaluation", "configuration-baseline", "configuration-item", "desktop-icons", "packages", "sccm", "windows-10"]
categories: ["configmgr-memcm-sccm", "microsoft", "windows-10"]
---

It started with a Tweet...

<!--more-->

I promised on Twitter that I would write this post if I had 20 peoples interest...

[![](/images/2019/05/desktopicons_sccm_1.jpg)](/images/2019/05/desktopicons_sccm_1.jpg)

### Background

We had a requirement to deploy Desktop Shortcuts, to the Windows 10 Public Desktop, for a new application. The shortcut was deployed using Group Policy Preferences (GPP). Below is a link to a nice article showing you how to do this:-

[https://blogs.technet.microsoft.com/askds/2014/02/17/adding-shortcuts-on-desktop-using-group-policy-preferences-in-windows-8-and-windows-8-1/](https://blogs.technet.microsoft.com/askds/2014/02/17/adding-shortcuts-on-desktop-using-group-policy-preferences-in-windows-8-and-windows-8-1/)

There was also a requirement to publish a "Custom" icon for each Desktop Shortcut.

### Why use a Configuration Item?

With SCCM there are lots of ways to "skin the cat". We can use an Application to deploy a single icon file and have the Application Detection Method detect the icon file. If the file doesn't exist it would get deployed to the client - nice and easy. Equally, we could use a Configuration Item for our detection logic (does the icon file exist) and then deploy a Package/Application, that puts the icon on the client, for any client that fails the Configuration Baseline Evaluation.

The purpose of this post is to show you how you "could" use Configuration Items in your Windows 10 environment. I have picked a relatively simple example and some may argue:- 
  
"Ben, why don't you just use GPP's for the Shortcut and an Application to deliver the custom .ico file?"  
  
I could!....... But i'm showing off Configuration Items :)

By the end of this post, I hope you will have a better understanding of how useful and flexible Configuration Items and Baseline are.

### What does this post cover?

1. [Brief overview of Configuration Items and Configuration Baselines](#Section1)
2. [Create an Application for the Custom Desktop Icon](#Section2)
3. [Create an Application for the Desktop Shortcut](#Section3)
4. [Create a Configuration Item/Baseline to detect if the Desktop Icon exists](#Section4)
5. [Create a Configuration Item/Baseline to detect if the Desktop Shortcut exists](#Section5)
6. [Understanding the Configuration Baseline Results](#Section6)
7. [Re-mediate any client that fails the Configuration Baseline Evaluation for the Desktop Icon](#Section7)
8. [Re-mediate any client that fails the Configuration Baseline Evaluation for the Desktop Shortcut](#Section8)

### 1\. Brief overview of Configuration Items and Configuration Baselines **[⏏](#NavMenu)**

Before we begin, it may help you to get an overview of Configuration Items (CI's) and Configuration Baselines CB's).

#### Configuration Item (CI)

A CI defines a collection of "Settings" that must meet a specific Condition (Compliance Rule) for that item to be then marked as Compliant.

**Example**

1. **"File C:\\Icon\\Icon1.ico"** ( <= Setting) **"Does the file Exist?"** ( <= Compliance Rule)
2. **"Registry Item HKLM\\Software\\PayRise /v Amount"** ( <= Setting) **"Does it = £1,000,000?"** ( <= Compliance Rule)  
    

<figure>

![](/images/2019/05/desktopicons_sccm_3-1024x431.jpg)

<figcaption>

Configuration Item (CI) Example

</figcaption>

</figure>

We can use the following settings when creating a CI:-

- Active Directory Query
- Assembly
- File System **(<= Using this one in our post)**
- IIS Metabase
- Registry Key
- Registry Value
- Script
- SQL Query
- WQL Query
- XPath Query

Different Settings will allow different remediation options. Some "Non Compliant" Settings can "Self Heal" in order to become Compliant.

#### Configuration Baseline (CB)

A CB is a collection of CI's that will be deployed to and evaluated by your clients. Upon evaluation of each of the CI's in the CB, a result of "Compliant" is returned only if ALL the CI's in the CB are evaluated as "Compliant". If only some of the CI's are evaluated as "Compliant" the overall evaluation will be "Not Compliant". It is therefore important that you take care when deciding a CI's membership with a CB.

**When will the Client evaluate the CB?**  
  
When you deploy a CB to a Collection, you can specify an evaluation schedule. The default Evaluation Schedule is 7 Days. Care should be taken when considering the Evaluation Schedule, especially if you are deploying scripts that could invoke lots of system resources. Do you really want to be checking for that Desktop Icon every minute?

When the Compliance of a CB is reported back to the server, we can create a Collection for all Clients that report the same Compliance status! Some CI Settings, like File System, are unable to automatically re-mediate so we create a Collection for our non Compliant Clients and we can then re-mediate them with other tools from the SCCM arsenal

<figure>

![](/images/2019/05/desktopicons_sccm_4.jpg)

<figcaption>

Create a new Collection for Non-Compliant Clients  

</figcaption>

</figure>

### 2\. Create an Application for the Custom Desktop Icon **[⏏](#NavMenu)**

In this section we will create an Application to deploy out custom .ico file

I like creating Applications to deliver files to Clients. Here are just a few reasons why:-

1. CCMCache. We can leverage Branche Cache, Peer Cache, Johnny Cash (SIC) and BITS throttling when delivering files to clients
2. We can use the same Application in a Task Sequence to deliver the same file during a IPU or Wipe and load OSD - less duplication = less admin work = more time to drink coffee
3. An Application allows me to identify if the file exists before it downloads to the clients local cache

#### Prerequisites

- Before we create the Application, place your custom .ico file and icon installation script on your normal "Content Location" UNC share (Step 8 has more details on what your "Content Location" folder should look like.
- On your Admin machine, also place your custom .ico file in C:\\Windows\\Icons (You will need to create this folder). We will need this in place for when we create our Desktop Shortcut later.

1 . From the SCCM Admin Console, navigate to **Software Library > Applications**. Right Click **Applications** and choose **Create Application**

<figure>

[![](/images/2019/05/desktopicons_sccm_5.jpg)](/images/2019/05/desktopicons_sccm_5.jpg)

<figcaption>

Create a New Application

</figcaption>

</figure>

2 . In the **Create Application Wizard**, choose **Manually Specify the Application Information** and click **Next**

<figure>

[![](/images/2019/05/desktopicons_sccm_7.jpg)](blob:https://byteben.com/96eb2b7b-2532-4b75-af42-26f5b5852b5f)

<figcaption>

Choose Manually Specify the Application Information

</figcaption>

</figure>

3 . Choose a **Name** for the new Application and click **Next**

<figure>

[![](/images/2019/05/desktopicons_sccm_8.jpg)](blob:https://byteben.com/83ee3fef-66a0-475b-9f9f-3efec6b8932a)

<figcaption>

Give your Application a Name

</figcaption>

</figure>

4 . We are not going to Display this Application in the Catalog so no need for a shiny icon or description. Click **Next**

<figure>

[![](/images/2019/05/desktopicons_sccm_9.jpg)](/images/2019/05/desktopicons_sccm_9.jpg)

<figcaption>

No need to customize here, we are not displaying this Application in the Catalog

</figcaption>

</figure>

5 . We need to add a Deployment Type so click **Add**

<figure>

[![](/images/2019/05/desktopicons_sccm_10.jpg)](blob:https://byteben.com/f4fd6ef9-2f2f-4d2d-aeb7-6f1f02ee88c3)

<figcaption>

Click "Add" to create a new Deployment Type

</figcaption>

</figure>

6 . Choose **Script Installer** from the Deployment Type drop down box and click **Next**

<figure>

[![](/images/2019/05/desktopicons_sccm_11.jpg)](blob:https://byteben.com/9df06493-6e03-4e3d-8813-dc846e845583)

<figcaption>

Choose "Script Installer" as the Deployment Type

</figcaption>

</figure>

7 . Give the Deployment Type a **Name** and click **Next**

<figure>

[![](/images/2019/05/desktopicons_sccm_12-1.jpg)](blob:https://byteben.com/73d3472e-caa6-4080-be85-25c5b95107a7)

<figcaption>

Give the Deployment Type a Name

</figcaption>

</figure>

8 . Specify the Application **Content Location** and **Installation Program** and click **Next**  
  
**Content Location:** "\\\\contentserver\\share\\Icons\\Awesome New App"  
**Installation Program:** Powershell.exe -ExecutionPolicy Bypass -File "Install\_Icon.ps1"

![](/images/2019/05/desktopicons_sccm_74.jpg)

**\*** When the Application is deployed, we will use a script to copy the .ico from the ccmcache folder to another local folder on the client. By using wildcards, we can re-use the same script when we look at deploying other .ico files to clients. An example of what the contents of the "Install\_Icon.ps1" script could be is:-

```
$IconsFolder = 'C:\Windows\Icons'
If (!(Test-Path -path $IconsFolder)) {New-Item $IconsFolder -Type Directory}
Copy-Item *.ico $IconsFolder -Force
```

Your **Content Location** should be looking something like this by now...

<figure>

[![](/images/2019/05/desktopicons_sccm_75.jpg)](/images/2019/05/desktopicons_sccm_75.jpg)

<figcaption>

Two files present in the Application Content Location

</figcaption>

</figure>

9 . Click **Add Clause**

<figure>

[![](/images/2019/05/desktopicons_sccm_15.jpg)](blob:https://byteben.com/a0baff80-1765-4afa-aaa2-13ae2fe42af1)

<figcaption>

Add a Clause for the Detection Method

</figcaption>

</figure>

10 . Now we set the Detection Rule. Choose **"FileSystem"** from for the **Setting Type** and set the following fields:-

1. **Type**: File
2. **Path**: C:\\Windows\\Icons
3. **File or Folder Name** Awesome\_New\_App\_Icon.ico

Click **O**K

<figure>

[![](/images/2019/05/desktopicons_sccm_16.jpg)](/images/2019/05/desktopicons_sccm_16.jpg)

<figcaption>

Set the Application Detection Rule

</figcaption>

</figure>

11 . Click **Next**

<figure>

[![](/images/2019/05/desktopicons_sccm_17.jpg)](blob:https://byteben.com/444b90f1-3eaf-4f6f-8aac-af62c2759a0c)

<figcaption>

Click Next after creating a Detection Rule

</figcaption>

</figure>

12 . Set the **User Experience** settings to the following values:-

1. **Installation Behavior:** Install for System
2. **Logon Requirement:** Whether or not a user is logged on
3. **Installation Program Visibility:** Hidden

Click **Next**

<figure>

[![](/images/2019/05/desktopicons_sccm_18.jpg)](blob:https://byteben.com/eaf6b8ed-f552-4966-a7f5-7d9513d9488d)

<figcaption>

Specify the User Experience Settings

</figcaption>

</figure>

13 . Click **Add** on the **Installation requirements for this deployment type** page

[![](/images/2019/05/desktopicons_sccm_19.jpg)](blob:https://byteben.com/a9fe9b2b-a082-45ea-b25c-84a2e426cbb9)

14 . On the **Create Requirement** page, select the following values:-

1. **Category:** Device
2. **Condition:** Operating System
3. **Operator:** Windows 10

Click **OK**

<figure>

[![](/images/2019/05/desktopicons_sccm_20.jpg)](blob:https://byteben.com/fa96225f-8d3a-40d5-8058-6d751737e068)

<figcaption>

Set the Requirement to Windows 10

</figcaption>

</figure>

15 . Click **Next**

<figure>

[![](/images/2019/05/desktopicons_sccm_21.jpg)](blob:https://byteben.com/908baa63-a21c-4cad-acda-29c2240cf2e4)

<figcaption>

After Adding the Application Requirement, click Next

</figcaption>

</figure>

16 . Click **Next** on the **Software Dependencies** screen (we wont be setting anything here)

17 . Click **Next** after reviewing the Summary

18 . Click **Close** to complete creating the Deployment Type

19 . Click **Next**

20 . Click **Next** again

21 . Click **Close** to complete the Application creation process

<figure>

![](/images/2019/05/desktopicons_sccm_22.jpg)

<figcaption>

Voila, we have our Application

</figcaption>

</figure>

### 3\. Create an Application for the Desktop Shortcut **[⏏](#NavMenu)**[](#NavMenu)

In this section we will create an Application to deploy our Desktop Shortcut. The steps are very similar to the previous section so we will omit screenshots.  
  
For the benefit and simplicity of this post, I am using a shortcut for calc.exe

#### Prerequisites

In the previous section we created an Application to deploy our custom .ico. We need to ensure that the Desktop Shortcut we create for use in this section points to the correct .ico file on our clients.

- Ensure the icon reference of the shortcut points to **C:\\Windows\\Icons\\Awesome\_New\_App.ico**
- Place your Desktop Shortcut and Desktop Shortcut installation script on your normal "Content Location" UNC share.  
    (Step 8 has more details on what your "Content Location" folder should look like.

<figure>

![](/images/2019/05/desktopicons_sccm_23.jpg)

<figcaption>

Your Desktop Shortcut should be pointing to the location your .ico will be deployed to on the clients

</figcaption>

</figure>

1 . From the SCCM Admin Console, navigate to **Software Library > Applications**.Right Click **Applications** and choose **Create Application**

2 . In the **Create Application Wizard**, choose **Manually Specify the Application Information** and click **Next**

3 . Choose a **Name** for the new Application and click **Next** e.g. **Awesome New App - Shortcut**

4 . We are not going to Display this Application in the Catalog so no need for a shiny icon or description. Click **Next**

5 . We need to add a Deployment Type so click **Add**

6 . Choose **Script Installer** from the Deployment Type drop down box and click **Next**

7 . Give the Deployment Type a **Name** and click **Next** e.g. **Awesome New App - Shortcut**

8 . Specify the Application **Content Location** and **Installation Program** and click **Next**  
  
**Content Location:** "\\\\contentserver\\share\\Shortcuts\\Awesome New App"  
**Installation Program:** Powershell.exe -ExecutionPolicy Bypass -File "Install\_Shortcut.ps1"

**\*** When the Application is deployed, we will use a script to copy the .lnk from the ccmcache folder to the Public Desktop on the client. By using wildcards, we can re-use the same script when we look at deploying other .lnk files to clients. An example of what the contents of the "Install\_Shortcut.ps1" script could be is:-

<figure>

[![](/images/2019/05/desktopicons_sccm_76.jpg)](blob:https://byteben.com/a188fdd1-49cd-459d-b2dc-3accaf1d2a61)

<figcaption>

The Content Location should contain your Shortcut and an Installation Script

</figcaption>

</figure>

```
$PublicDesktop = 'C:\Users\Public\Desktop'
If (Test-Path -path $PublicDesktop) {Copy-Item *.lnk $PublicDesktop -Force}
```

9 . Click **Add Clause**

10 . Now we set the Detection Rule. Choose **"FileSystem"** from for the **Setting Type** and set the following fields:-

1. **Type**: File
2. **Path**: C:\\Users\\Public\\Desktop
3. **File or Folder Name** Awesome New App.lnk

Click **O**K

11 . Click **Next**

12 . Set the **User Experience** settings to the following values:-

1. **Installation Behavior:** Install for System
2. **Logon Requirement:** Whether or not a user is logged on
3. **Installation Program Visibility:** Hidden

Click **Next**

13 . Click **Add** on the **Installation requirements for this deployment type** page

14 . On the **Create Requirement** page, select the following values:-

1. **Category:** Device
2. **Condition:** Operating System
3. **Operator:** Windows 10

Click **OK**

15 . Click **Next**

16 . Click **Next** on the **Software Dependencies** screen (we wont be setting anything here)

17 . Click **Next** after reviewing the Summary

18 . Click **Close** to complete creating the Deployment Type

19 . Click **Next**

20 . Click **Next** again

21 . Click **Close** to complete the Application creation process

### 4\. Create a Configuration Item/Baseline to detect if the Desktop Icon exists **[⏏](#NavMenu)**

In this section we will create a Configuration Item and Baseline to evaluate if the required .ico file is on the client

1 . From the SCCM Admin Console, navigate to **Assets and Compliance > Compliance Settings > Configuration Items > Create Configuration Item**

<figure>

[![](/images/2019/05/desktopicons_sccm_25.jpg)](blob:https://byteben.com/5ea3fc89-ff41-48cf-beb9-0f0bd1ff26fd)

<figcaption>

Create a Configuration Item

</figcaption>

</figure>

2 . Specify general information about the CI

- **Name**: Awesome New App - Icon
- **Type of Configuration:** Windows Desktops and Servers (custom)

Click **Next**

<figure>

[![](/images/2019/05/desktopicons_sccm_26.jpg)](blob:https://byteben.com/ae5fdd95-8407-4a77-9003-fb370e48e8cf)

<figcaption>

Set some general information for this CI

</figcaption>

</figure>

3 . Choose your supported platforms, in our case **Windows 10**, and click **Next**

<figure>

[![](/images/2019/05/desktopicons_sccm_27.jpg)](blob:https://byteben.com/4a1e8ade-5e5d-473a-8852-c7c97129ac2d)

<figcaption>

Choose the supported platforms for this CI

</figcaption>

</figure>

4 . Click **New** to add a setting for us to evaluate in this CI

<figure>

[![](/images/2019/05/desktopicons_sccm_28.jpg)](blob:https://byteben.com/fd0230c4-80d9-4131-a8dc-2f77cf3973a4)

<figcaption>

Click New to add a setting to evaluate in this CI

</figcaption>

</figure>

5 . Add the following information into your CI Setting. Remember the Setting is the item you are looking to evaluate. In our case we are going to evaluate C:\\Windows\\Icons\\Awesome\_New\_App.ico as specified in [Section 2](#Section2)

- **Name:** Awesome New App - Icon
- **Setting Type:** File system
- **Path:** C:\\Windows\\Icons
- **File or Folder Name:** Awesome\_New\_App.ico

Click the **Compliance Rules** tab

<figure>

[![](/images/2019/05/desktopicons_sccm_29.jpg)](blob:https://byteben.com/422fc7d0-f6b6-464f-8d44-18e649af4eb3)

<figcaption>

Add some setting information to the CI

</figcaption>

</figure>

6 . Click **New**

<figure>

[![](/images/2019/05/desktopicons_sccm_30.jpg)](blob:https://byteben.com/73d244a0-e31e-4e3f-82b3-22c63e1a968a)

<figcaption>

Click New

</figcaption>

</figure>

7 . Specify the following Compliance Rule settings

- **Name:** Awesome New App - Icon
- **Rule Type:** Existential
- **Setting:** File must exist on client devices

Click **OK**

<figure>

[![](/images/2019/05/desktopicons_sccm_31.jpg)](/images/2019/05/desktopicons_sccm_31.jpg)

<figcaption>

Specify Compliance Rule Settings

</figcaption>

</figure>

8 . Click **OK**

<figure>

[![](/images/2019/05/desktopicons_sccm_32.jpg)](blob:https://byteben.com/01c8a983-e445-4d7c-9089-e19b935646cb)

<figcaption>

Click OK in the Create Setting window

</figcaption>

</figure>

9 . Click **Next**

<figure>

[![](/images/2019/05/desktopicons_sccm_33.jpg)](blob:https://byteben.com/203de4da-065f-49a5-82e1-3d2e5c2b9a15)

<figcaption>

Click Next

</figcaption>

</figure>

10 . Click **Next**

<figure>

[![](/images/2019/05/desktopicons_sccm_34.jpg)](/images/2019/05/desktopicons_sccm_34.jpg)

<figcaption>

Click Next

</figcaption>

</figure>

11 . Click **Next**

<figure>

[![](/images/2019/05/desktopicons_sccm_35.jpg)](/images/2019/05/desktopicons_sccm_35.jpg)

<figcaption>

Click Next

</figcaption>

</figure>

12 . Click **Close**

<figure>

[![](/images/2019/05/desktopicons_sccm_36.jpg)](blob:https://byteben.com/47614dea-6062-4c0f-ab67-6215352947cb)

<figcaption>

Click Close

</figcaption>

</figure>

Now that we have created the CI we can go ahead to create the CB to deploy to our clients

13 . From the SCCM Admin Console, navigate to **Assets and Compliance > Compliance Settings > Configuration Baselines > Create Configuration Baseline**

<figure>

[![](/images/2019/05/desktopicons_sccm_37.jpg)](blob:https://byteben.com/e4a9ac08-1c3e-4a79-980b-94939ba18496)

<figcaption>

Create a new Configuration Baseline

</figcaption>

</figure>

14 . Give the CB a name e.g. **Awesome New App - Icon**

<figure>

[![](/images/2019/05/desktopicons_sccm_39.jpg)](blob:https://byteben.com/7c1bc712-a2eb-4934-89e6-d7917c4830da)

<figcaption>

Name your CB

</figcaption>

</figure>

15 . Click **Add > Configuration Items**, select the CI we created previously and click **Add**

<figure>

[![](/images/2019/05/desktopicons_sccm_40.jpg)](blob:https://byteben.com/3e11ea66-3c73-4a49-a24d-4375335845c5)

<figcaption>

Select the CI and click Add

</figcaption>

</figure>

16 . Click **OK**

<figure>

[![](/images/2019/05/desktopicons_sccm_41.jpg)](blob:https://byteben.com/34fca682-27ec-43a9-88d8-952ace747a9a)

<figcaption>

Click OK

</figcaption>

</figure>

17 . Click **OK**

<figure>

[![](/images/2019/05/desktopicons_sccm_42.jpg)](/images/2019/05/desktopicons_sccm_42.jpg)

<figcaption>

Click OK

</figcaption>

</figure>

18 . Select your new CB and click **Deploy** from the ribbon toolbar

<figure>

![](/images/2019/05/desktopicons_sccm_43.jpg)

<figcaption>

Highlight the CB to Deploy

</figcaption>

</figure>

19 . Click **Browse** to select the Collection to deploy this CB to

<figure>

[![](/images/2019/05/desktopicons_sccm_44.jpg)](blob:https://byteben.com/0ff666bd-8435-4756-9a0b-e44eb41a0ef5)

<figcaption>

Click Browse

</figcaption>

</figure>

20 . Select your desired Collection to deploy this CB to and click **OK**

<figure>

[![](/images/2019/05/desktopicons_sccm_45.jpg)](/images/2019/05/desktopicons_sccm_45.jpg)

<figcaption>

Select your desired Collection to deploy the CB to

</figcaption>

</figure>

21 . Select an Evaluation Schedule. This is how often your client will evaluate the CB. In this example, we will evaluate the CB once per day  
  
Click **OK**

<figure>

[![](/images/2019/05/desktopicons_sccm_46.jpg)](/images/2019/05/desktopicons_sccm_46.jpg)

<figcaption>

Select an Evaluation Schedule and click OK

</figcaption>

</figure>

### 5\. Create a Configuration Item/Baseline to detect if the Desktop Shortcut exists **[⏏](#NavMenu)**

In this section we will create a Configuration Item and Baseline to evaluate if the required .lnk file is on the clients Public Desktop. The process is similar to Section 4 so we will omit screenshots

1 . From the SCCM Admin Console, navigate to **Assets and Compliance > Compliance Settings > Configuration Items > Create Configuration Item**

2 . Specify general information about the CI

- **Name**: Awesome New App - Shortcut
- **Type of Configuration:** Windows Desktops and Servers (custom)

Click **Next**

3 . Choose your supported platforms, in our case **Windows 10**, and click **Next**

4 . Click **New** to add a setting for us to evaluate in this CI

5 . Add the following information into your CI Setting. Remember the Setting is the item you are looking to evaluate. In our case we are going to evaluate "C:\\Users\\Public\\Desktop\\Awesome New App.lnk" as specified in [Section 3](#Section3)

- **Name:** Awesome New App - Shortcut
- **Setting Type:** File system
- **Path:** C:\\Users\\Public\\Desktop
- **File or Folder Name:** Awesome New App.lnk

Click the **Compliance Rules** tab

6 . Click **New**

7 . Specify the following Compliance Rule settings

- **Name:** Awesome New App - Shortcut
- **Rule Type:** Existential
- **Setting:** File must exist on client devices

Click **OK**

8 . Click **OK**

9 . Click **OK**

10 . Click **Next**

11 . Click **Next**

12 . Click **Close**

Now that we have created the CI we can go ahead to create the CB to deploy to our clients

13 . From the SCCM Admin Console, navigate to **Assets and Compliance > Compliance Settings > Configuration Baselines > Create Configuration Baseline**

14 . Give the CB a name e.g. **Awesome New App - Shortcut**

15 . Click **Add > Configuration Items**, select the CI we created previously and click **Add**

16 . Click **OK**

17 . Click **OK**

18 . Select your new CB and click **Deploy** from the ribbon toolbar

19 . Click **Browse** to select the Collection to deploy this CB to

20 . Select your desired Collection to deploy this CB to and click **OK**

21 . Select an Evaluation Schedule. This is how often your client will evaluate the CB. In this example, we will evaluate the CB once per day

Click **OK**

### 6\. Understanding the Configuration Baseline Results **[⏏](#NavMenu)**

The clients will evaluate the two CB's at the schedule you set. In our example, once per day. We can see the results of the evaluation either on the client or in the console

<figure>

[![](/images/2019/05/desktopicons_sccm_47-1024x557.jpg)](blob:https://byteben.com/d41dff4d-715b-40b6-b5d5-18ac6d4c5693)

<figcaption>

Compliance Results as seen in the Console

</figcaption>

</figure>

<figure>

[![](/images/2019/05/desktopicons_sccm_48-1024x656.jpg)](/images/2019/05/desktopicons_sccm_48.jpg)

<figcaption>

Compliance Results as seen on the Client

</figcaption>

</figure>

If we click **View Report** from the client, we can see some more information for the Compliance Result and reason for Non-Compliance  
  
This CB evaluated as Non-Compliant because:-

1. The CI was Non Compliant... because...
2. The setting being evaluated (does file exist) was not present
3. Because there was not 100% CI Compliance, the Baseline resulted in Non-Compliant

<figure>

[![](/images/2019/05/desktopicons_sccm_49-1024x637.jpg)](blob:https://byteben.com/4fcfc250-f952-42ff-ad58-8adc0100b026)

<figcaption>

Configuration Baseline Evaluation Report

</figcaption>

</figure>

While we are here, load **C:\\Windows\\CCM\\Cmtrace.exe** on the client and open **C:\\Windows\\CCM\\Logs\\CIAgent.log** to view the CI Evaluation log

<figure>

[![](/images/2019/05/desktopicons_sccm_50-1024x480.jpg)](/images/2019/05/desktopicons_sccm_50.jpg)

<figcaption>

CIAgent.log

</figcaption>

</figure>

We have established that both CB's are **Non-Compliant** meaning we have neither the Desktop Shortcut or Desktop .ico file on our clients.

Some CI's, when marked as **Non-Compliant**, can be set to automatically re-mediate in the CB settings. For example when using Registry Values and Scripts as Compliance Conditions

<figure>

[![](/images/2019/05/desktopicons_sccm_51.jpg)](/images/2019/05/desktopicons_sccm_51.jpg)

<figcaption>

Some CI's can self heal like lizards

</figcaption>

</figure>

We don't have the ability to do this when dealing with files. Isn't it handy we created some Applications earlier! We can use these Applications to re-mediate the **Non-Compliant** clients

### 7\. Re-mediate any client that fails the Configuration Baseline Evaluation for the Desktop Icon **[⏏](#NavMenu)**

In [Section 6](#Section6) we looked at the evaluation status of the CB's in the SCCM console. We will now deploy the Application we created in [Section 2](#Section2) to any **Non-Compliant** client

1 . From the SCCM Admin Console, navigate to **Assets and Compliance > Compliance Settings > Configuration Baselines**

1. Select the Baseline where you wish to deploy the Application **Awesome New App - Icon** to **Non-Compliant** clients
2. Select the **Deployments** tab
3. Select the **Deployment**
4. On the Ribbon menu, click **Create New Collection** and choose **Non-Compliant**

<figure>

[![](/images/2019/05/desktopicons_sccm_52-1024x644.jpg)](blob:https://byteben.com/787e796e-fd3f-4cbc-a4ae-9506b290b648)

<figcaption>

Create Collection from Configuration Baseline Deployment Panel

</figcaption>

</figure>

2 . In the **Create Device Collection** wizard, click **Next**

<figure>

![](/images/2019/05/desktopicons_sccm_53.jpg)

<figcaption>

Click Next

</figcaption>

</figure>

3 . In the **Define Membership Rules for this Collection** window, click **Next**

<figure>

[![](/images/2019/05/desktopicons_sccm_54.jpg)](blob:https://byteben.com/c95a09ad-0af2-4078-903a-d15a0ec534d0)

<figcaption>

Click Next

</figcaption>

</figure>

4 . Click **Next** in the Summary Windows

<figure>

[![](/images/2019/05/desktopicons_sccm_55.jpg)](blob:https://byteben.com/3e17c44c-6f4d-4ab6-9b90-416a5725b5fe)

<figcaption>

Click Next

</figcaption>

</figure>

5 . Click **Close** to complete the **Create Device Collection Wizard**

[![](/images/2019/05/desktopicons_sccm_56.jpg)](blob:https://byteben.com/9617e979-dd69-44cf-9ba7-4005c43d769f)

All Collections created from a CB are placed in **Assets and Compliance > Device Collections > Devices and Collections**

<figure>

[![](/images/2019/05/desktopicons_sccm_57-1024x390.jpg)](blob:https://byteben.com/d102d4bd-faaf-4bb5-8e63-382906b5f8fb)

<figcaption>

The new Collection is in the root of the **Device Collections** folder

</figcaption>

</figure>

6 . To deploy our **Awesome New App - Icon** Application to this Collection

1. **Highlight** the Collection
2. On the Ribbon menu, click **Deploy**
3. Select **Application**

<figure>

[![](/images/2019/05/desktopicons_sccm_58.jpg)](blob:https://byteben.com/fbc1cad1-dff2-4b34-8a26-18f4eaf24c99)

<figcaption>

Deploy an Application to the Non-Compliant Configuration Baseline Collection

</figcaption>

</figure>

7 . In the **Deploy Software Wizard**, click **Browse**

<figure>

[![](/images/2019/05/desktopicons_sccm_59.jpg)](/images/2019/05/desktopicons_sccm_59.jpg)

<figcaption>

Click Browse

</figcaption>

</figure>

8 . Select **Awesome New App - Icon** and click **OK**

<figure>

[![](/images/2019/05/desktopicons_sccm_60.jpg)](/images/2019/05/desktopicons_sccm_60.jpg)

<figcaption>

Select the Application to Deploy and click OK

</figcaption>

</figure>

9 . Click **Next**

[![](/images/2019/05/desktopicons_sccm_61.jpg)](/images/2019/05/desktopicons_sccm_61.jpg)

10 . Click **Add** and choose a **Distribution Point** or **Distribution Point Group** to distribute the Application Content to

<figure>

[![](/images/2019/05/desktopicons_sccm_62.jpg)](blob:https://byteben.com/683180ba-2119-4bde-93cb-80606bd292d1)

<figcaption>

Distribute the Content for the Application

</figcaption>

</figure>

11 . Select the **Distribution Point** or **Distribution Point Group** and click **OK**

<figure>

![](/images/2019/05/desktopicons_sccm_63.jpg)

<figcaption>

Select the Distribution Point or Distribution Group and click OK

</figcaption>

</figure>

12 . Click **Next**

<figure>

[![](/images/2019/05/desktopicons_sccm_64.jpg)](blob:https://byteben.com/aa3c8263-3dd9-4521-85b3-1951c7032b04)

<figcaption>

Click Next

</figcaption>

</figure>

13 . Select **Required** from the drop down list and click **Next**

<figure>

[![](/images/2019/05/desktopicons_sccm_66.jpg)](blob:https://byteben.com/e0d090c4-19a0-4a96-8b2b-e1687e835d91)

<figcaption>

Select Required for the purpose of the Deployment

</figcaption>

</figure>

14 . To Deploy the Application ASAP, leave these setting as Default and click **Next**

<figure>

[![](/images/2019/05/desktopicons_sccm_67.jpg)](blob:https://byteben.com/ec2f7435-d834-4fbc-8220-7350b2cf8c51)

<figcaption>

Click Next

</figcaption>

</figure>

15 . In the **User Notifications** drop down box, choose **Hide in Software Center and all Notifications** and click **Next**

<figure>

[![](/images/2019/05/desktopicons_sccm_68.jpg)](blob:https://byteben.com/8ccd62d0-f178-4fd0-b471-282d3b75b180)

<figcaption>

Choose to hide the Application in Software Center - we don't want the user interacting with this Application

</figcaption>

</figure>

16 . Click **Next**

<figure>

[![](/images/2019/05/desktopicons_sccm_69.jpg)](/images/2019/05/desktopicons_sccm_69.jpg)

<figcaption>

We will leave Deployment alerts off for this Deployment

</figcaption>

</figure>

17 . Click **Next**

<figure>

[![](/images/2019/05/desktopicons_sccm_70.jpg)](blob:https://byteben.com/0fb42ce7-12c4-48d1-aff6-482ac9e9b6b0)

<figcaption>

Click Next

</figcaption>

</figure>

18 . Click **Close**

<figure>

[![](/images/2019/05/desktopicons_sccm_71.jpg)](blob:https://byteben.com/0550e9f3-7b47-43e5-9d87-0e58d6e66a40)

<figcaption>

Click Close

</figcaption>

</figure>

At the next Computer Policy refresh interval, the Policy Agent will run and our clients will get the new Deployment for **Awesome New App - Icon**

We can check **C:\\Windows\\CCM\\Logs\\AppDiscovery.log**

<figure>

[![](/images/2019/05/desktopicons_sccm_72-1024x470.jpg)](blob:https://byteben.com/138e0a87-e0f5-424a-8c0a-3df10140c379)

<figcaption>

AppDiscovery.log gives us an indication that the Application was not detected so it will be installed

</figcaption>

</figure>

Voila, we have our .ico file in our folder

<figure>

[![](/images/2019/05/desktopicons_sccm_73.jpg)](blob:https://byteben.com/7bdf4331-6b4e-4e33-a674-884f0e43892f)

<figcaption>

Application successfully deployed the .ico file to our folder on the client

</figcaption>

</figure>

At the next CB evaluation schedule, because the .ico is now on the client, the CB should return a Compliance State of **Compliant**

<figure>

![](/images/2019/05/desktopicons_sccm_77.jpg)

<figcaption>

Evaluation showing the Configuration Baseline as Compliant

</figcaption>

</figure>

If we check back in the SCCM Console, the Compliance status for clients in the CB will be updated (be patient)

<figure>

![](/images/2019/05/desktopicons_sccm_78-1024x527.jpg)

<figcaption>

Clients will start to come back into Compliance

</figcaption>

</figure>

### 8\. Re-mediate any client that fails the Configuration Baseline Evaluation for the Desktop Shortcut **[⏏](#NavMenu)**

In [Section 7](#Section7) we looked at re-mediating Clients that did not have our custom .ico file. In this section we will perform similar steps to re-mediate the missing Desktop Shortcut on **Non-Compliant** Clients. We will omit screenshots in this section as they are similar to the previous section

1 . From the SCCM Admin Console, navigate to **Assets and Compliance > Compliance Settings > Configuration Baselines**

1. Select the Baseline where you wish to deploy the Application **Awesome New App -** Shortcut to **Non-Compliant** clients
2. Select the **Deployments** tab
3. Select the **Deployment**
4. On the Ribbon menu, click **Create New Collection** and choose **Non-Compliant**

2 . In the **Create Device Collection** wizard, click **Next**

3 . In the **Define Membership Rules for this Collection** window, click **Next**

4 . Click **Next** in the Summary Windows

5 . Click **Close** to complete the **Create Device Collection Wizard**

6 . To deploy our **Awesome New App - Icon** Application to this Collection

1. **Highlight** the Collection
2. On the Ribbon menu, click **Deploy**
3. Select **Application**

7 . In the **Deploy Software Wizard**, click **Browse**

8 . Select **Awesome New App - Shortcut** and click **OK**

9 . Click **Next**

10 . Click **Add** and choose a **Distribution Point** or **Distribution Point Group** to distribute the Application Content to

11 . Select the **Distribution Point** or **Distribution Point Group** and click **OK**

12 . Click **Next**

13 . Select **Required** from the drop down list and click **Next**

14 . To Deploy the Application ASAP, leave these setting as Default and click **Next**

15 . In the **User Notifications** drop down box, choose **Hide in Software Center and all Notifications** and click **Next**

16 . Click **Next**

17 . Click **Next**

18 . Click **Close**

As in the previous section for our custom .ico, at the next Computer Policy refresh interval, the Policy Agent will run and our clients will get the new Deployment for **Awesome New App - Shortcut**

We can see in C:\\Windows\\CCM\\Logs\\AppEnforce.log that the Application was installed

<figure>

[![](/images/2019/05/desktopicons_sccm_79.jpg)](blob:https://byteben.com/212f95fa-eefc-4205-b9d3-08b19128363c)

<figcaption>

AppEnforce.log shows Application Installing successfully

</figcaption>

</figure>

We can also see our new Desktop Shortcut...using our custom .ico file!

<figure>

![](/images/2019/05/desktopicons_sccm_80.jpg)

<figcaption>

Awesome New App.lnk is copied to the Client and the reference to the .ico in C:\\Windows\\Icons is working

</figcaption>

</figure>

### Conclusion **[⏏](#NavMenu)**[](#NavMenu)

In this, long, post we learned how to create an Application for our our new Desktop Shortcut and our custom .ico file. We also looked at creating Configuration Items and Configuration Baselines to identify Clients that were missing the Desktop Shortcut or custom .ico file. We then deployed those Applications to the Non-Compliant clients and re-mediated them.

As i said at the beginning of this post, there are lots of ways to skin the SCCM cat. I personally use Group Policy Preferences to deliver the Shortcut but then use an SCCM Application to deliver, when required, a custom .ico file

I hope I have given you an understanding of how you could use Configuration Items and Configuration Baselines in your environment to re-mediate some of the daily challenges us admins face.