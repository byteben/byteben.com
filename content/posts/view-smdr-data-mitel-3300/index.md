---
title: "How to view SMDR data on a Mitel 3300 Controller"
date: 2013-05-26
categories:
  - "Mitel"
  - "Mitel 3300"
tags: ["mitel", "mitel-3300", "mitel-smdr", "smdr-cos"]
categories: ["mitel", "mitel-3300"]
---

Lets keep this one short and sweet, 3 words...<!--more-->

TELNET PORT 1752

Alas, I need to say more. It is true that SMDR can be seen simply by telneting to port 1752 of the IP address of your ICP. If you see no SMDR data on port 1752, you may need to check if the COS for your Trunks allows SMDR. Here is how:-

1. Open a web browser and point it to the IP Address of your Mitel 3300.
2. Log in.
3. Open the "System Administration Tool".
4. Drill down to your "Class Of Service Options" form (Under System Properties, System Feature Settings).
5. Highlight the COS (Class of Service) that is applied to your incoming/Outgoing Trunks.
6. Click "Change".
7. Scroll down until you get to the SMDR section.[![How to view SMDR data on a Mitel 3300 Controller](/images/2013/05/How-to-view-SMDR-data-on-a-Mitel-3300-Controller.jpg)](http://byteben.com/bb/images/2013/05/How-to-view-SMDR-data-on-a-Mitel-3300-Controller.jpg)
8. Flick both settings to "Yes" (External Trunk SMDR is given preference over station to station i.e. Internal SMDR when both these are on).
9. Save the form.
10. Ta da.

You can now Telnet to you ICP IP address on port 1752 and watch the SMDR data stream across your screen like ceefax has gone out of fashion. You can also point any 3rd party IP buffer to the same IP/PORT to log your SMDR data for reporting and such like.

```
telnet x.x.x.x 1752
```

(where x.x.x.x is your ICP IP Address)

[![How to view SMDR data on a Mitel 3300 Controller](/images/2013/05/How-to-view-SMDR-data-on-a-Mitel-3300-Controller-2.jpg)](http://byteben.com/bb/images/2013/05/How-to-view-SMDR-data-on-a-Mitel-3300-Controller-2.jpg)

Thats it. Job done.

## How to view SMDR data on a Mitel 3300 Controller

### How to view SMDR data on a Mitel 3300 Controller