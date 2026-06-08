---
title: "Mitel 3300 Voicemail Port Crashed"
date: 2012-09-30
categories:
  - "Mitel"
  - "Mitel 3300"
tags: ["ipvm_start", "ipvm_stop", "mitel", "mitel-3300", "mitel-voicemail-port", "putty"]
---

Ok, so this happens fairly infrequently but the following command is useful for when it does - it saves having to reboot the controller. You either get one or more voicemail ports lock up and this manifests itself normally when your users stat to complain that they cant dial into voicemail. If your voicemail group is set as a Terminal group and it is the first port that is locked/crashed it is easy to identify when there is a problem - because your helpdesk gets pummeled by frustrated users.

<!--more-->

Download something like Putty [http://www.putty.org/](http://www.putty.org/ "Putty") so we can create a raw connection to our controller.

You will need to connect to the IP Address of your controller on port 2002 using the RAW connection option (see below)

\[caption id="attachment\_118" align="alignnone" width="300"\][![Mitel 3300 Voicemail Port Crashed](/images/2012/09/Mitel-3300-Voicemail-Port-Crashed-300x287.jpg "Mitel 3300 Voicemail Port Crashed")](http://byteben.com/bb/images/2012/09/Mitel-3300-Voicemail-Port-Crashed.jpg) Putty Connection Options\[/caption\]

Login with Administrator credentials and then issue the following command. It IS case sensitive:-

```
iPVM_Stop
```

Wait for the command prompt to return focus and then issue the following command:-

```
iPVM_Start
```

Ignore the error that pops up afterwards.

Job done, disconnect your Putty session and your voicemail ports should be back up and running, the helpdesk should be quiet again and you can go make another coffee.

## Mitel 3300 Voicemail Port Crashed

### Mitel 3300 Voicemail Port Crashed