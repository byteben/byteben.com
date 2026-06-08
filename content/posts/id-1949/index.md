---
title: "Demystifying the Office 365 Click to Run Update Process with SCCM"
draft: true
---

In the following post we will try and demystify the Office 365 Click to Run (C2R) process. We will cover the following items and see how they affect updating:-

<!--more-->

1. Office Configuration Tool
2. Client Settings
3. Group Policy
4. Update Payload
5. The OfficeMgmtCom COM+ Application
6. Changes in Content download behavior
7. Update Channels

### Background

Without modification to the Configuration.xml, SCCM Client Settings or GPO, the Office 365 Pro Plus client will connect to Microsoft Content Delivery Network (CDN) to get its updates. Microsoft made a change and started listing the meta data for the Office 365 Client in WSUS around 2016 when we saw SCCM (1602) supporting updating the Office 365 Client using the Software Update mechanism.

Some "non SCCM" folks got all giddy and after seeing the meta data published in WSUS assumed they could distribute the updates using only the Windows Update Client and WSUS - they were mistaken. The meta data was intended solely for SCCM.

SCCM is unique in that it can enable a COM+ Application to mange the update process. It can, among other things, tell the client to get the content from a Distribution Point. This COM+ Application is key in the update process, we will go into more detail later on, for now, let us call it out - **OfficeMgmtCom**

The Microsoft folks were quite awesome here. By allowing API calls to a new COM+ Application they ensured we could get content in a "managed" way, similar to how we get other updates from SCCM. Instead of every client trundling off to the CDN we can leverage technologies like Peer Cache to get our updates circulated among clients.

Before we see some magic, smoke and mirrors we have to tell our clients not to go off to the CDN. This can be done using the Office Configuration Tool, SCCM Client Setting or Group Policy. Lets look at these first.

### 1\. Office Configuration Tool