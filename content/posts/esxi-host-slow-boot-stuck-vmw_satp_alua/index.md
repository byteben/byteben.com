---
title: "ESXi Host Slow Boot stuck on vmw_satp_alua"
date: 2018-08-15
categories:
  - "VMware"
---

So I came across this recently while upgrading ESXi hosts. Part of the phased migration to vSphere 6.7 was to get our ESXi hosts from version 5.5 to version 6.0. The normal applied, evacuate the vms using DRS, put it in maintenenace mode, attach the ESXi 6.0 baseline upgrade, remediate the host and......3 hours later the host appears on the radar. What! 3 Hours?

<!--more-->

One clue here was the ESXi bootloader seemed to be "stuck" on vmw\_satp\_alua. So why was the boot process being delayed by scanning my storage paths? We took a jump across to our vmkernel.log and saw this line (one of many)

2018-08-15T06:20:29.191Z cpu12:33249)NMP: nmp\_ResetDeviceLogThrottling:3440: Error status H:0x0 D:0x18 P:0x0 Sense Data: 0x5 0x24 0x0 from dev "naa.6000d31000086f000000000000004e3b" occurred 2533 times(of 2536 commands)

> **Error status H:0x0 D:0x18 P:0x0 Sense Data: 0x5 0x24 0x0**

D:0x18 Indicates the Device Status has a Reservation Conflict. This device is an RDM mapped to the host but more importantly the device is part of a Microsoft Disk Cluster (often referred to as partaking in a MSCS or Microsoft Cluster Service)

We then come acroos the VMware KB [https://kb.vmware.com/s/article/1016106](https://kb.vmware.com/s/article/1016106)

So the ESXi host was scanning all the RDMs but getting stuck (delayed) when trying to discover any LUN taking part in a MSCS. The host is unable to interrogate the LUN due to the persistent ISCSI reservation placed on the device by the active node in the MSCS cluster.

Fortunately this is expected behaviour, which means there is a workaround. We can set a "Perennially Reserved Flag" ( you will be forgiven trying to pronounce that before you have had coffee). This will tell the host to skip scanning that LUN at boot, esentially speeding up your boot time.

Before we show you how to do this, lets point something out. It is important, IMO, that the "Perennially Reserved Flag" only be set on the RDMs that are taking part in your MSCS. Setting this flag accidentally on a LUN that is a VMFS datastore could, in VMwares words, result in data loss.

To set the flag run:-

esxcli storage core device setconfig -d _naa-id_ --perennially-reserved=TRUE

esxcli storage core device setconfig -d naa.6000d31000086f000000000000004e3b --perennially-reserved=TRUE

You can discover if the device has the flag set by running:-

esxcli storage core device list -d _naa.id_

esxcli storage core device list -d naa.6000d31000086f000000000000004e3b

![](http://byteben.com/bb/images/2018/08/perennially_reserved-1.jpg)

Remember, these commands will need to be applied to each applicable ESXi host. Some really intelligent people have some great examples of using PowerShell in PowerCLI to make this job easier for larger environments.