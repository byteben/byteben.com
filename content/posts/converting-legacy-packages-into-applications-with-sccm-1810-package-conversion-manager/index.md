---
title: "Converting legacy packages into applications with SCCM 1810 Package Conversion Manager"
date: 2019-01-30
categories:
  - "ConfigMgr / MEMCM / SCCM"
  - "Microsoft"
---

### Background

Since SCCM 2012 Microsoft have been steering us towards using "applications" to install apps over the traditional "packages" method. Applications give us additional benefits over packages like detection methods, dependencies and requirement rules . An example might be:-

<!--more-->

Install APP-B if the folder "C:\\Program Files\\APP-B\_FOLDER" doesn't exist **(detection)**, only if APP-A is already installed **(prerequisite)** and it is a Windows 10 device **(requirement)**.

Package Conversion Manager, in its former life, was a separate tool you could download to convert legacy packages into applications. In SCCM Current Branch 1806 we saw the "Package Conversion Manager" as a pre-release feature. Starting in SCCM CB 1810 "Package Conversion Manager" is the full ticket, all beefed up-integrated and ready to destroy your legacy packages one by one (quote not in the official marketing material).

### **Planning Package Conversion**

Note: Package Conversion will not delete or modify your existing packages. Upon conversion a new application will be created and the original package will remain unaffected by the process.

Microsoft recommend that you have a good conversion plan in place before you begin converting legacy packages. They give a good example of what your plan may look like at [https://docs.microsoft.com/en-us/sccm/apps/pcm/package-conversion-manager#planning](https://docs.microsoft.com/en-us/sccm/apps/pcm/package-conversion-manager#planning)

Your plan may look like this (Example) :-

- [Define a detailed package conversion plan](https://docs.microsoft.com/en-us/sccm/apps/pcm/package-conversion-manager#bkmk_define)
- [Select and prepare packages for conversion](https://docs.microsoft.com/en-us/sccm/apps/pcm/package-conversion-manager#bkmk_prepare)
- [Select Test Packages](https://docs.microsoft.com/en-us/sccm/apps/pcm/package-conversion-manager#bkmk_test)
- [Analyze, investigate and convert packages](https://docs.microsoft.com/en-us/sccm/apps/pcm/package-conversion-manager#bkmk_analyze)
- [Test and deploy the new application](https://docs.microsoft.com/en-us/sccm/apps/pcm/package-conversion-manager#bkmk_deploy)

### Can all Packages be reborn as shiny applications?

Not really. There are some software and scripted procedures that are just not cut out to be converted into applications. All applications must have a detection method so SCCM can see if the application already exists - this may not work for packages that are required to run on a recurring basis. That being said, I would always try and use an application first before resorting to a package - applications are just so much more versatile.

### Where can I find Package Conversion Manager?

You can find the "Package Conversion Status" on the monitoring tab. This will show you an overview of the Package Conversion to date.

<figure>

![](/images/2019/01/app_conver_23.jpg)

<figcaption>

Package Conversion Status is found on the "Monitoring" tab.

</figcaption>

</figure>

[![](/images/2019/01/app_conver_1-1024x318.jpg)](/images/2019/01/app_conver_1.jpg)The "Package Conversion Status" dashboard

We can also find Package Conversion options in our Software Library - Packages. The available commands on the ribbon bar will depend on the Package Conversion Status for the selected package.

[![](/images/2019/01/app_conver_24-1024x329.jpg)](/images/2019/01/app_conver_24.jpg)"Package Conversion" command in the Ribbon Bar

### Analysing Packages

In the following package conversion example, we will take the humble Notepad++ package. Notepad ++ can and should be created as an Application in the first instance but she makes a good candidate in the lab - so lets go.

1 . Highlight the package you want to convert (1) and click "Analyze Package" (2)

[![](/images/2019/01/app_conver_25-1024x365.jpg)](/images/2019/01/app_conver_25.jpg) Highlight the Package and click "Analyze Package"

2 . The pop-up window will indicate the current package is being analyzed. If you want to dive under the hood, open **SMSPROV.LOG** 

[![](/images/2019/01/app_conver_3-1024x543.jpg)](blob:https://byteben.com/3742f054-4b11-458b-a59b-f84ab4b9bf51)smsprov.log parsing the processing of Package BB100013 (Notepad ++)

and when package analyzing has finished

[![](/images/2019/01/app_conver_7-1024x100.jpg)](blob:https://byteben.com/e8f30025-9fa8-40a9-99dd-8c6c93cbb33e)Finished analyzing package BB100013

3 . Once package analysis has completed, you will see the outcome of the analysis in the "Readiness" column.

<figure>

![](/images/2019/01/app_conver_26.jpg)

<figcaption>

Package Readiness state after analysis

</figcaption>

</figure>

Our Notepad++ package requires "Manual" intervention before she can become an application. The readiness states are:-

- Automatic
- Manual
- Error

Automatic means we can go right ahead and convert package into an application with no manual intervention.

Manual means we gotta tweak some stuff ourselves (see below).

Error just means your trying this on a Monday morning with no coffee.

**PCMTrace.log** will help you diagnose why an error occurred. More info on troubleshooting error codes can be found at [https://docs.microsoft.com/en-us/sccm/apps/pcm/error-messages](https://docs.microsoft.com/en-us/sccm/apps/pcm/error-messages)

### Converting Packages

Lets take our humble Notepad++ package. She is just a few steps away from being given a set of new shiny wings.

For any package that has a readiness state of "Automatic" the "Convert Package" command is available on the ribbon bar. Ours has a readiness state of "Manual" and thus the command "Fix and Convert" command is available.

1 . Highlight your package that as a readiness state of "Manual" and choose "Fix and Convert" from the ribbon.

<figure>

![](/images/2019/01/app_conver_27.jpg)

<figcaption>

Choose "Fix and Convert" from the ribbon bar

</figcaption>

</figure>

2 . The "Package Conversion Wizard" will open. Take note of the remedial steps that are required to convert this package into an application. In our case, we need to provide a "Detection Method".

[![](/images/2019/01/app_conver_8-1024x796.jpg)](/images/2019/01/app_conver_8.jpg)

3 . Click "Next".

4 . Review any Dependencies (none in our example) and click "Next".

[![](/images/2019/01/app_conver_9-1024x876.jpg)](blob:https://byteben.com/eb5db101-0eef-434b-ae0b-c1644b04fe14)Dependency Review

5 . Review the Deployment. In our example we can see that an application detection method is required.

<figure>

![](/images/2019/01/app_conver_10-1024x881.jpg)

<figcaption>

Detection Method Required

</figcaption>

</figure>

6 . We cannot proceed with "Next" until this item is resolved. Highlight the row and click "Edit".

We will now be required to choose a detection method for this application. More on application detection methods can be found at [https://docs.microsoft.com/en-us/sccm/apps/deploy-use/create-applications#bkmk\_dt-detect](https://docs.microsoft.com/en-us/sccm/apps/deploy-use/create-applications#bkmk_dt-detect)

For our example package, our application detection method will be "File Version is equal to x".

7 . Click "Add Clause".

[![](/images/2019/01/app_conver_11-1024x884.jpg)](/images/2019/01/app_conver_11.jpg)Application Detection Clause

8 . Fill in the Detection Rule logic and click "Ok".

[![](/images/2019/01/app_conver_12-1024x1024.jpg)](blob:https://byteben.com/3a48255e-21b4-4694-b79a-c94e50459976)Application Detection Logic

9 . Click "Ok".

[![](/images/2019/01/app_conver_13-1024x886.jpg)](blob:https://byteben.com/923f1826-ac2a-4b5c-ab21-39f1874e3dd1)New Detection Method Added

Now we have fulfilled the earlier requirement to provide an app detection method, our previous red icon with a cross should be replaced with a green icon with a tick.

10 . Click "Next"

![](/images/2019/01/app_conver_14-1024x876.jpg)

> On the **Requirements Selection** page, review the deployment types of the new application. Select a deployment type, and review the requirements for that deployment type
> 
> https://docs.microsoft.com/en-us/sccm/apps/pcm/how-to-analyze-and-convert

11 . Tick the "Requirement" for the deployment and Click "Next"

[![](/images/2019/01/app_conver_15-1024x876.jpg)](blob:https://byteben.com/9c7b92e7-41ef-48eb-926c-97a2fe5bcaa1)Tick the box for luck

12 . Review the settings and click "Next"

![](/images/2019/01/app_conver_16-1024x870.jpg)

13 . Click "Close" - job done!

[![](/images/2019/01/app_conver_17-1024x881.jpg)](/images/2019/01/app_conver_17.jpg)Application Conversion Complete

### Review the New Application

If we head back over to "Software Library - Packages" we should see the readiness state for our package now says "Converted"

<figure>

![](/images/2019/01/app_conver_28-1024x187.jpg)

<figcaption>

Package Converted

</figcaption>

</figure>

and then switching to "Applications" we should see our shiny new Notepad ++ application

<figure>

![](/images/2019/01/app_conver_29-1024x267.jpg)

<figcaption>

New Application Created

</figcaption>

</figure>

and if we head over to the "Monitoring - Package Conversion" tab, our Package Conversion Status has been updated

![](/images/2019/01/app_conver_20-1024x301.jpg)

### And the best part

What else don't we like about packages...no Software Centre icon...urghh! If we deployed Notepad ++ right now we would see this

![](/images/2019/01/app_conver_21-1024x582.jpg)

But now Notepad ++ is an Application, we can assign a big shiny icon! (Fist punch the air)

![](/images/2019/01/app_conver_22-1024x550.jpg)

### Summary

I really like this feature. We are trying to get our customers to try and self service before they call or email the Service Desk. The better we can make that experience in the Software Centre the more time we get to play with Technical Previews and eat chicken wings.

Package Conversion Manager and the Application Approval process in 1810 are great new features that keep moving us ever closer to never having to manually intervene in any application delivery scenario.

Note: One thing I did fire off to support was there doesn't seem to be any syntax checking in the wizard for applications that already exist with the same name. I ended up with quite a new "Notepad ++" applications in the lab - normally we are prevented from creating applications with the same name. Fixed in 1902! Thanks @adammeltzer