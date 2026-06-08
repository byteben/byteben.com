---
title: "Block the Office File Transfer Endpoints to help prevent data leakage on Managed Devices"
date: 2022-08-08
---

In this post we will look at the Office File Transfer feature and implement a simple solution to prevent "one way" that users can leak corporate data.

<!--more-->

## Mobile Devices - The Trojan Horse of Security

In this fast paced landscape, security teams are having to constantly respond to both new and legacy vulnerabilities to help protect us, our data and our devices. Sometimes, a curve ball will come at you and bring you out in a cold sweat - "oh geez, how did we miss this hole?!"

As my good friend @mauriced says, "Mobile devices are the smallest computers that you own" - and he is right! They can also be, by their very nature, the trickiest of devices to manage. Several years ago, it wasn't uncommon for companies to issue corporate devices for employees to access corporate emails and documents. Those days are rapidly "going-going-gone" (almost) and users expect to be able to access corporate data from their personal mobile device. Using a combination of Conditional Access and App Protection Policies we have relatively good control over that experience to prevent, or at least drastically limit, corporate data leakage into the users personal apps.

<figure>

[![](/images/2022/05/image-56.png)](/images/2022/05/image-56.png)

<figcaption>

App Protection Policies

</figcaption>

</figure>

Mobile Devices still prove to be that Trojan Horse that Compliance and Security Administrator's fear. One reason, that echo's true still today, is that no matter what controls you put in place how are you going to prevent someone taking a photo of sensitive data?

## Microsoft Office app for mobile devices

The Microsoft Office app, for mobile devices, is generally well known and **can** be protected with App Protection Policies from Intune.

[![](/images/2022/05/image-57.png)](/images/2022/05/image-57.png)

### File Transfer

An often overlooked feature in the Microsoft Office app is **File Transfer**. This feature can be accessed from the actions menu.

<figure>

[![](/images/2022/05/image-58.png)](/images/2022/05/image-58.png)

<figcaption>

File Transfer Feature

</figcaption>

</figure>

After tapping Send or Receive, the user is prompted to pair their device by visiting **transfer.office.com** on their computer.

<figure>

[![](/images/2022/05/image-59.png)](/images/2022/05/image-59.png)

<figcaption>

Pair your devices

</figcaption>

</figure>

The user is prompted to scan the QR code to pair the mobile device with the computer before being able to transfer files.

<figure>

[![](/images/2022/05/image-64-1024x490.png)](/images/2022/05/image-64.png)

<figcaption>

Pair devices and transfer files

</figcaption>

</figure>

### App Protection Policies

As per the Microsoft docs [https://docs.microsoft.com/en-us/office365/troubleshoot/access-management/control-file-transfer](https://docs.microsoft.com/en-us/office365/troubleshoot/access-management/control-file-transfer)

You can transfer only locally stored, non-managed data from a mobile phone to the desktop. You can't transfer Intune-protected, organization-managed, or cloud files. The File Transfer feature follows the policies for Intune Mobile Application Management (MAM) that are applied on the Office app.

So we are good right? We can't transfer data from Intune-protected apps that have been targeted with an App Protection Policy...

### A chink in the armour

While it may be true that App Protection Policies can prevent corporate data being sent from a mobile device, what protections are there to prevent Windows devices from sending data to the Office mobile app? Let's explore this scenario with a personal iOS device that does not have any app protection policies targeted.

<figure>

[![](/images/2022/05/image-65-1024x561.png)](/images/2022/05/image-65.png)

<figcaption>

Pair Devices

</figcaption>

</figure>

<figure>

[![](/images/2022/05/image-67.png)](/images/2022/05/image-67.png)

<figcaption>

Choose files to send to mobile device

</figcaption>

</figure>

<figure>

[![](/images/2022/05/image-68.png)](/images/2022/05/image-68.png)

<figcaption>

Choose files to send

</figcaption>

</figure>

<figure>

[![](/images/2022/05/image-69.png)](/images/2022/05/image-69.png)

<figcaption>

Files sent to mobile device

</figcaption>

</figure>

<figure>

[![](/images/2022/05/image-70.png)](/images/2022/05/image-70.png)

<figcaption>

Corporate files sent to mobile device

</figcaption>

</figure>

Wow! As you can see, we were able to transfer corporate files, from a "managed" Windows device to an "unmanaged" personal device. We didn't even need to sign into the Microsoft Office app on the mobile device to prove our corporate identity.

## Workaround

After climbing down from the ceiling in shock, the easiest way I could find to prevent this "back door data leak" scenario is to block managed devices from accessing the **transfer.office.com** URL(s)/IP's. Microsoft call out the IP's and URL's in the following doc which will effectively turn off the ability for Windows devices to leverage the file transfer feature.

[https://docs.microsoft.com/en-us/office365/troubleshoot/access-management/control-file-transfer#turn-off-file-transfer](https://docs.microsoft.com/en-us/office365/troubleshoot/access-management/control-file-transfer#turn-off-file-transfer)

**URL's to block**

- filetransfer-prod-griffin-\*.cloudapp.net
- transfer.office.com
- filetransfer.trafficmanager.net

**IP's to block**

- 13.76.241.194
- 52.184.64.21
- 65.52.31.49
- 70.37.107.67
- 52.169.19.3

### Defender for Endpoint

Here is a feather to add to the bow of persuasion for those still on the fence about Microsoft Defender. Defender for Endpoint Plan 1 and Plan 2 includes the ability to create indicators for IPs and URLs/domains. More reading on that below.

[https://docs.microsoft.com/en-us/microsoft-365/security/defender-endpoint/manage-indicators?view=o365-worldwide](https://docs.microsoft.com/en-us/microsoft-365/security/defender-endpoint/manage-indicators?view=o365-worldwide)

Indicators allow you to detect and prevent access to known file hashes, IP addresses, URL's and Certificates (.cer and .pem).

### Create Indicator to block access to transfer.office.com

1 . Navigate to the Microsoft Security Portal and ensure the **Custom network indicators** advanced feature is enabled  
  
[https://security.microsoft.com/preferences2/integration](https://security.microsoft.com/preferences2/integration)

<figure>

[![](/images/2022/05/image-71-1024x388.png)](/images/2022/05/image-71.png)

<figcaption>

Custom network indicators

</figcaption>

</figure>

2 . From the same portal, navigate to **Indicators**

<figure>

[![](/images/2022/05/image-72.png)](/images/2022/05/image-72.png)

<figcaption>

Indicators

</figcaption>

</figure>

3 . Navigate to **IP addresses**, click **Add Item**, enter the **IP address** to block and click **Next**

<figure>

![](/images/2022/05/image-73-1024x738.png)

<figcaption>

Add IP address

</figcaption>

</figure>

4 . Choose the action to **Block execution**. Check **Generate alert** and enter an **Alert title**. Choose an **Alert severity** and **Category** for this alert.

<figure>

[![](/images/2022/05/image-74.png)](/images/2022/05/image-74.png)

<figcaption>

Add Alert Actions

</figcaption>

</figure>

5 . Enter a **Description** for the alert and click **Next**

<figure>

[![](/images/2022/05/image-75.png)](/images/2022/05/image-75.png)

<figcaption>

Alert Description

</figcaption>

</figure>

6 . Review the alert information and click **Save**

<figure>

[![](/images/2022/05/image-76.png)](/images/2022/05/image-76.png)

<figcaption>

Alert Summary

</figcaption>

</figure>

7 . Repeat steps 3 to 7 for the other IP addresses listed in the Microsoft doc

- 13.76.241.194
- 52.184.64.21
- 65.52.31.49
- 70.37.107.67
- 52.169.19.3

<figure>

[![](/images/2022/05/image-77-1024x361.png)](/images/2022/05/image-77.png)

<figcaption>

All Indicators added

</figcaption>

</figure>

When a user attempts to initiate a file transfer for corporate data on their managed device, they will be blocked

<figure>

[![](/images/2022/05/image-78.png)](/images/2022/05/image-78.png)

<figcaption>

IP/URL Blocked

</figcaption>

</figure>

You can monitor these block events from the Defender Portal too (if you enabled alerting when creating the indicators).

## Summary

In this post we demonstrated how users can move corporate data from a managed Windows device to a personal mobile device. We then looked at how we could use Microsoft Defender to block access to the required IP's for the Office transfer endpoints using Indicators.

This type of data extraction can be leveraged from many other apps and services. Do you allow WhatsApp, Signal and other cloud services on users work devices? What do you have in place to prevent data transfer across those services? Are you going to add Indicators for all of those IP's and URL's too?

My main motivation and hope for this post is to get you thinking. Yes we closed one back door, killed off one trojan horse, but the challenges are many. Go spark a conversation with your team - how well do you understand your current position for protecting corporate data for the multitude of Cloud services that exist today.