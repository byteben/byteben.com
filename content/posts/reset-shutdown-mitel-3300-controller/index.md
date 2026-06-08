---
title: "How to Reset or Shutdown a Mitel 3300 Controller"
date: 2012-10-01
categories:
  - "Mitel"
  - "Mitel 3300"
tags: ["mitel", "mitel-3300", "mitel-3300-reset", "mitel-3300-shutdown", "mitel-reset"]
---

Fairly basic thing right? Right! Open a web browser and point it to the IP Address of your Mitel 3300. Depending on the version you are running (because this route has change a few times between the MCD versions you want to find "Maintenance Commands".

<!--more-->To issue a reboot (otherwise know as a warm reset) enter the following command and press "Submit"

```
reset system
```

Now this options does not restart the controller, only the callserver. To reboot the APC you will need to do this via the server manager (not covered in this topic)

To issue a shutdown of the controller, enter the following command and press "Submit"

```
shutdown
```

I like to have a raw session on port 2002 open at the same time so I can see what the VM is doing as it shutsdown. The display tells you that you can cycle the power button after 60seconds - I like to leave it a few minutes just to make sure the shutdown has completed fully and cleanly.

Flip your power button/s on the back of the controller off for 10seconds and then flick them back on again. If you have a large estate give the system at least 15mins to come up before you start to panic, all the handsets need to check back in again and this is alot of IP traffic to deal with for a poor 3300 that has just been switched on from cold.

## How to Reset or Shutdown a Mitel 3300 Controller

### How to Reset or Shutdown a Mitel 3300 Controller