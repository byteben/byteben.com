---
title: "AppSense Environment Manager Event IDs"
date: 2013-06-23
tags: ["amc", "appsense", "appsense-environmentmanager", "appsense-environment-manager-agent", "cca-events", "desktopnow", "event-id"]
categories: ["appsense", "appsense-desktopnow", "appsense-environmentmanager"]
---

AppSense DesktopNow offers the tech heads among us a wide range of Event IDs that can be generated from the endpoint CCA (Client Communications Agent). Some are classed as "High Priority Events". These are non configurable and are sent direct to the AMC (AppSense Managment Centre) database via HTTP from the endpoint when they are generated. Other, configurable, events are sent by the CCA to the AMC database during the default poll period set on the distribution group. <!--more-->These events are stored locally in an .evt format. At each poll period, set on the deployment group, the CCA will zip the .evt file and transfer it to the AMC using BITS. You will normally find the .evt file in the "_C:\\Program Files\\AppSense\\Management Center\\CCA\\Upload"_ folder. I am only going to deal with Environment Manager Event IDs here in this article.

**NOTE:** If it helps, ALL Environment Manager event IDs are in the 93xx - 96xx Event ID range. A full, comprehensive Event ID guide can be found in the "Management Center Product Guide" available on [http://www.myappsense.com](http://www.myappsense.com)

Below are the predefined, non configurable, High Priority Events for EM:-

```
  Event Description
  9390   The Environment Manager Agent ended unexpectedly.
  9391   The Environment Manager Agent has restarted.
  9392   The Environment Manager Agent has been terminated due to being in the starting or stopping state for a prolonged period.
  9393   The Environment Manager Agent has exceeded its maximum restart attempts.
  9495   AppSense Environment Manager has not been configured.
  9496   An old configuration has been found
```

Those configurable (you can switch them on or off) events that can be managed for Environment Manager are:-

```
  Event   Event Type     Event Name
  9300    Information    Self healing process started
  9301    Information    Self healing registry key replaced
  9302    Information    Self healing registry key removed
  9303    Information    Self healing file replaced
  9304    Information    Self healing file removed
  9305    Information    Self healing service stopped
  9306    Information    Self healing service started Self healing service started
  9307    Information    Self healing registry value replaced
  9308    Information    Self healing registry removed
  9399    Warning        Software is not licensed
  9400    Information    Lockdown edit control blocked drive
  9401    Information    Lockdown edit control blocked text
  9402    Information    Lockdown accelerator keys blocked
  9403    Information    Lockdown dialog blocked
  9404    Information    Lockdown MSAA access blocked
  9405    Information    User logon action success
  9406    Information    User logon action fail
  9407    Information    User logoff action success
  9408    Information    User logoff action fail
  9409    Information    Computer startup action success
  9410    Information    Computer startup action fail
  9420    Information    User session reconnect action success
  9421    Information    User session reconnect action fail
  9422    Information    User session disconnect action success
  9423    Information    User session disconnect action fail
  9424    Information    User session locked action success
  9425    Information    User session locked action fail
  9426    Information    User session unlocked action success
  9427    Information    User session unlocked action fail
  9428    Information    Process start action success
  9429    Information    Process start action fail
  9430    Information    Process stopped action success
  9431    Information    Process stopped action fail
  9432    Information    Network connection action success
  9433    Information    Network connection action fail
  9434    Information    Network disconnected action success
  9435    Information    Network disconnected action fail
  9495    Warning        Not configured (EM)
  9496    Warning        Configuration unsupported
  9501    Information    Removable storage device has been disabled
  9502    Information    Removable storage device has read-only access
  9600    Error          Failed to connect to Personalization Database
  9601    Error          Windows Impersonation Logon Failed.
  9602    Error          Failed Database Compatibility Check
  9650    Information    Managed application start
  9651    Information    Managed application stop
  9652    Error          Personalization load error
  9653    Error          Personalization save error
  9654    Information    Blacklisted process started
  9655    Information    Personalization not saved
  9656    Information    Offline resiliency save started
  9657    Information    Offline resiliency save complete
  9658    Information    Personalization settings purged
  9659    Information    Personalization settings updated
  9660    Error          Personalization failed
  9661    Warning        Timeout Communicating with Personalization Server
  9662    Information    Trigger Action Times
```

That is it really. Another helpful tip (thanks Richard Kelly@QA for this) is that ALL AppSense DesktopNow Event IDs ending in xx99 are to do with licencing issues.

## AppSense Environment Manager Event IDs

### AppSense Environment Manager Event IDs