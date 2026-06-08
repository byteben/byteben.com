---
title: "LANDesk 9.5 SP1 Inventory Scan Missing 32-bit Applications from Add or Remove Programs Inventory"
date: 2013-09-20
categories:
  - "Landesk"
  - "Landesk Managment Suite"
---

So you have upgraded your LDMS Core and Agents to 9.5 SP1. Everything looks tickety boo and you notice some of your software queries are not working anymore. Upon further investigation you notice that you are missing applications in "add and remove programs" in your software inventory. The ldiscn32.exe packaged in SP1 is not returning 32-bit applications to your inventory. Bumpers! Run for the hills...<!--more-->

The version of ldiscn32.exe packaged with LANDesk Managment Suite 9.5 SP1 is 9.5.2.66. If you copy a previous version of the ldiscn32.exe file to an affected agent and re-run an inventory collection you will see that the inventory is returned correctly (this is not the fix).

Compare how your Inventory looks before and after the upgrade:-

**Before**

[![LANDesk 9.5 SP1 Inventory Scan Missing 32-bit Applications from Add or Remove Programs Inventory](/images/2013/09/LANDesk-9.5-SP1-Inventory-Scan-Missing-32-bit-Applications-from-Add-or-Remove-Programs-Inventory2.jpg)](http://byteben.com/bb/images/2013/09/LANDesk-9.5-SP1-Inventory-Scan-Missing-32-bit-Applications-from-Add-or-Remove-Programs-Inventory2.jpg)

**After**

[![LANDesk 9.5 SP1 Inventory Scan Missing 32-bit Applications from Add or Remove Programs Inventory](/images/2013/09/LANDesk-9.5-SP1-Inventory-Scan-Missing-32-bit-Applications-from-Add-or-Remove-Programs-Inventory.jpg)](http://byteben.com/bb/images/2013/09/LANDesk-9.5-SP1-Inventory-Scan-Missing-32-bit-Applications-from-Add-or-Remove-Programs-Inventory.jpg)

You will notice the list is a lot less populated and missing your 32bit apps.

LANDesk have released a new CR75998-95 BETA patch for this issue. The patch contains a new version of ldiscn32.exe (9.50.3.2) that addresses this problem. More details can be found on this LANDesk [article](http://community.landesk.com/support/docs/DOC-29217). At the time of writing this blog, the patch had to be requested from support.

That is all :)