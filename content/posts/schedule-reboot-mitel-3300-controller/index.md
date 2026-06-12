---
title: "How to schedule a reboot on a Mitel 3300 Controller"
date: 2015-09-16
tags: ["mitel-3300", "mitel-3300-reset", "mitel-3300-scheduled-reboot"]
categories: ["mitel", "mitel-3300"]
---

So you need to reboot your Mitel controller but don't fancy hanging around until 2am to do it (despite the overtime). Your friend is the "Programmed Reboot" maintenance command.

<!--more-->

We need to do this occasionally to free up dynamic memory that gets chewed up by crashed iPVM and call processing.  First job is to log into your Mitel 3300 and go to "Maintenance Commands".

1. In the maintenance command window, type:-
    
    > PROGRAMMED REBOOT DISPLAY
    
2. Your current programmed reboot schedule is displayed. [![How to schedule a reboot on a Mitel 3300 Controller](/images/2015/09/How-to-schedule-a-reboot-on-a-Mitel-3300-Controller-1.jpg)](http://byteben.com/bb/images/2015/09/How-to-schedule-a-reboot-on-a-Mitel-3300-Controller-1.jpg)
3. If you are happy with the current schedule, simply switch on the schedule by issuing the command:-
    
    > PROGRAMMED REBOOT SCHEDULE ON
    
4. You can change the schedule by using the following command (in this example I want to reboot my controller on Friday at 3AM-
    
    > PROGRAMMED REBOOT SCHEDULE FRIDAY 03:00
    
5. You may only want to set a schedule and reboot the system if resources have been compromised or a non critical resource fails. In this case, set the following command (and switch on the schedule):-
    
    > PROGRAMMED REBOOT RESOURCE: RECOVERY FRIDAY 03:00
    
    > PROGRAMMED REBOOT RESOURCE RECOVERY ON
    
6. Another useful command only reboots the system if there are no active calls.
    
    > PROGRAMMED REBOOT COURTESY ON
    
7. Don't forget to switch the schedules off the next day if you only intended a one off reboot of the system

Hope that helps someone out.