---
title: "How to find what numbers are in use on a Mitel 3300"
date: 2013-06-10
tags: ["free-directory-number", "loc-num", "locate-number", "mitel", "mitel-3300", "mitel-commands"]
categories: ["mitel", "mitel-3300"]
---

Want to find what directory numbers are in use on your Mitel 3300? Consider this..being the company Mitel 3300 administrator, you get a call from the Service Desk. "Mr Bond wants 007 extension number allocated to his new BYOD watch please". Here is a quick way to tell if that directory number is already in use on your PBX.<!--more-->

1. Open a web browser and point it to the IP Address of your Mitel 3300. Depending on the version you are running (because this route has change a few times between the MCD versions you want to find "Maintenance Commands.[![How to find what numbers are in use on a Mitel 3300](/images/2013/06/How-to-find-what-numbers-are-in-use-on-a-Mitel-3300.jpg)](http://byteben.com/bb/images/2013/06/How-to-find-what-numbers-are-in-use-on-a-Mitel-3300.jpg)
2. In the "command" input box, type "Locate Number". (This input box supports auto complete, another quick alternative is to simply type "LOC NUM")
3. Followed by the number you wish to find. e.g. "Locate Number 6300" and hit the Submit button (newer versions of MCD support hitting the Enter key too).

[![How to find what numbers are in use on a Mitel 3300](/images/2013/06/How-to-find-what-numbers-are-in-use-on-a-Mitel-3300-2.jpg)](http://byteben.com/bb/images/2013/06/How-to-find-what-numbers-are-in-use-on-a-Mitel-3300-2.jpg)

If the number is in use, you will get a result to that effect in the "System Response" window. In this example the number 6300 is already allocated to a system speedcall. If the directory number is free, you will get a "number not in use" message.

I love these short posts, no need to over complicate this matter.

##  How to find what numbers are in use on a Mitel 3300

### How to find what numbers are in use on a Mitel 3300