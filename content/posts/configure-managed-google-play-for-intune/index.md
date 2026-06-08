---
title: "Configure Managed Google Play for Intune"
date: 2019-03-23
categories:
  - "Intune"
  - "Microsoft"
tags: ["android-enrollment", "android-enterprise", "intune", "managed-google-play", "msintune", "work-profile"]
categories: ["intune", "microsoft"]
---

Before you can start using Android Enterprise Work Profiles, or enroll your Android Devices into Intune, you have to link Managed Googled Play.  
Google Managed Play allows you to select, purchase, and manage apps for your organization. You can create lists of approved apps and manage updates.

<!--more-->

This quick post will guide you through creating an account for Google Managed Play, configuring it for Intune and adding some apps from the Managed Google Play store into your Intune Client Apps Catalog.

### Prerequisites

You will need a [Google Account](https://myaccount.google.com/) to complete the setup of Managed Google Play. For the following post, we:-

1. Created a Google Account for Managed Play
2. Opened our Default Browser (Intune will launch a new window, in the Default Browser, to setup Managed Google Play)
3. Logged in to the Google Account

**Note:** _If you are signed into a personal Google Account in your default browser, this account will be used to link Managed Google Play to Intune_

### Configuring Managed Google Play for Intune

1 . Connect to [https://devicemanagement.microsoft.com](https://devicemanagement.microsoft.com)

2 . Select **Device enrollment**

<figure>

[![](/images/2019/03/googleplay_1-1024x603.jpg)](blob:https://byteben.com/08384b30-d96b-48b5-b004-b33a522b9b6c)

<figcaption>

Select Device enrollment

</figcaption>

</figure>

3 . Select **Android enrollment**

<figure>

[![](/images/2019/03/googleplay_2-1024x649.jpg)](/images/2019/03/googleplay_2.jpg)

<figcaption>

  
Select Android enrollment

</figcaption>

</figure>

4 . Select **Managed Google Play**

<figure>

[![](/images/2019/03/googleplay_3-1024x648.jpg)](blob:https://byteben.com/b1560802-f97e-4400-855d-26c5472db397)

<figcaption>

Select Managed Google Play

</figcaption>

</figure>

6 . Select **I Agree** ([Learn More about the data Intune sends to Google)](https://go.microsoft.com/fwlink/?linkid=866317)  

<figure>

[![](/images/2019/03/googleplay_4-1024x646.jpg)](/images/2019/03/googleplay_4.jpg)

<figcaption>

Select I Agree

</figcaption>

</figure>

7 . Click **Launch Google to Connect Now** (You proxy must allow access to [https://play.google.com)](https://play.google.com)

<figure>

[![](/images/2019/03/googleplay_5-1024x766.jpg)](blob:https://byteben.com/26859df6-6523-4cf0-876e-f5b8624840cd)

<figcaption>

Click Launch Google to Connect Now

</figcaption>

</figure>

8 . Select **Get Started**

![](/images/2019/03/googleplay_6-1024x732.jpg)

9 . Enter your **Business name** and click **Next**

<figure>

![](/images/2019/03/googleplay_7-1024x776.jpg)

<figcaption>

Enter your Business name

</figcaption>

</figure>

10 . If you are in the EU, and adhere to GDPR guidelines, enter the contact details of the Data Protection Officer and EU Representative (This information can be entered at a later date

<figure>

[![](/images/2019/03/googleplay_8-1024x1002.jpg)](/images/2019/03/googleplay_8.jpg)

<figcaption>

Enter GDPR Contact Details

</figcaption>

</figure>

11 . Agree to the Terms and Conditions for Managed Google Play set out at [https://www.android.com/enterprise/terms/](https://www.android.com/enterprise/terms/)

<figure>

[![](/images/2019/03/googleplay_9.jpg)](/images/2019/03/googleplay_9.jpg)

<figcaption>

Agree to the Managed Google Play Terms

</figcaption>

</figure>

12 . Click **Complete Registration**

<figure>

[![](/images/2019/03/googleplay_10.jpg)](/images/2019/03/googleplay_10.jpg)

<figcaption>

Complete Registration

</figcaption>

</figure>

13 . Switch back to your Intune Window to view the completed Managed Google Play setup

<figure>

[![](/images/2019/03/googleplay_11-1024x594.jpg)](/images/2019/03/googleplay_11.jpg)

<figcaption>

Managed Google Play Setup Complete

</figcaption>

</figure>

### Next Steps

Now we have configured Managed Google Play, our Android enrollment options become available

<figure>

[![](/images/2019/03/googleplay_12-1024x794.jpg)](blob:https://byteben.com/ccc41bae-e707-475e-8714-8eb1efff1d39)

<figcaption>

Android enrollment options are now available

</figcaption>

</figure>

We can now add Managed Google Play **apps** from the **Client Apps** blade. Lets look at this in some more detail

### Adding Managed Google Play Apps to Intune

1 . Select **Client apps > Apps**

<figure>

[![](/images/2019/03/googleplay_13-1024x603.jpg)](/images/2019/03/googleplay_13.jpg)

<figcaption>

Select Client apps > Apps

</figcaption>

</figure>

2 . Select **+** **Add**

<figure>

[![](/images/2019/03/googleplay_14-1024x590.jpg)](blob:https://byteben.com/ca786f8d-5361-47d7-b1c9-13cc0a255e3e)

<figcaption>

Select Apps

</figcaption>

</figure>

3 . From the **App type** drop down box, select **Managed Google Play**

<figure>

[![](/images/2019/03/googleplay_15.jpg)](blob:https://byteben.com/21d36c66-cae8-49d1-b145-035724c6c01c)

<figcaption>

Select Managed Google Play

</figcaption>

</figure>

4 . Select **Approve**

<figure>

[![](/images/2019/03/googleplay_16.jpg)](/images/2019/03/googleplay_16.jpg)

<figcaption>

Select Approve

</figcaption>

</figure>

5 . In the **Search** box, type the name of the app you want to add and click the **Blue Search Icon**

**Note:** _The client you are working from will need access to the Google Play Store_

<figure>

[![](/images/2019/03/googleplay_17-1024x622.jpg)](blob:https://byteben.com/fc9f0fd4-d9df-45c4-b642-60773272816a)

<figcaption>

Search for the app from Google Play

</figcaption>

</figure>

6 . Select the App

<figure>

[![](/images/2019/03/googleplay_18-1024x813.jpg)](blob:https://byteben.com/865f07c9-2576-40d5-8eb0-bd94a1bbbb9c)

<figcaption>

Select the App  

</figcaption>

</figure>

7 . Select **Approve**

[![](/images/2019/03/googleplay_19-1024x398.jpg)](blob:https://byteben.com/4e4fc91b-dd5c-40be-b7af-11f154105ab7)

8 . Acknowledge what Device Information the app will have access to and Select **Approve**

<figure>

[![](/images/2019/03/googleplay_20-1024x814.jpg)](blob:https://byteben.com/c9c851af-867c-49df-8085-9d6f5eabcc19)

<figcaption>

Select Approve

</figcaption>

</figure>

9 . Choose how to handle new app permission changes, how to be notified of these changes and Select **Save**

<figure>

[![](/images/2019/03/googleplay_21-1024x696.jpg)](/images/2019/03/googleplay_21.jpg)

<figcaption>

Choose how to handle new app permission changes and Select Save

</figcaption>

</figure>

10 . Select **Ok**

<figure>

[![](/images/2019/03/googleplay_22-1024x590.jpg)](blob:https://byteben.com/a9034f94-47ab-43a3-a97a-4b117518b691)

<figcaption>

Select Ok

</figcaption>

</figure>

11 . Select **Sync** to import the app into the Client App catalog

<figure>

[![](/images/2019/03/googleplay_23-680x1024.jpg)](blob:https://byteben.com/20059155-2ecd-45b8-9955-3ae88770e3ac)

<figcaption>

Select Sync

</figcaption>

</figure>

After a few moments, the app will be available in **Client apps**

<figure>

![](/images/2019/03/googleplay_24-1024x289.jpg)

<figcaption>

App is now available in Client apps

</figcaption>

</figure>

### Next Steps

This concludes setting up Managed Google Play for Intune. Our next steps will be:-

1. Create an App Protection Policy (recommended) [https://docs.microsoft.com/en-us/intune/app-protection-policies](https://docs.microsoft.com/en-us/intune/app-protection-policies)
2. Create an App Configuration Policy (optional) [https://docs.microsoft.com/en-us/intune/app-configuration-policies-use-android](https://docs.microsoft.com/en-us/intune/app-configuration-policies-use-android)
3. Assign the app (required) [https://docs.microsoft.com/en-us/intune/apps-inc-exl-assignments](https://docs.microsoft.com/en-us/intune/apps-inc-exl-assignments)