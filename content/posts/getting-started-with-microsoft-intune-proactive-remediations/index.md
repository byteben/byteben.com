---
title: "Getting Started with Microsoft Intune Proactive Remediations"
date: 2020-09-09
categories:
  - "Intune"
  - "Microsoft"
  - "Windows 10"
tags: ["endpoint-analytics", "mempowered", "msintune", "proactive-remediations"]
---

In this Lab video we dive into a feature of Endpoint Analytics in Microsoft Intune called "Proactive Remediations"

<!--more-->

I give a high level overview of what Proactive Remediations are and an example of how we can use them to remediate invalid client registry settings. For the scenario presented during the lab, the clients were enabled for co-management and had a legacy GPO that had disabled Automatic Updates. The clients were internet connected and had no VPN to reach the domain for a Group Policy Update to reverse the legacy Group Policy setting. A Proactive Remediation script was an easy way to change the registry key for those internet connected clients.

https://www.youtube.com/watch?v=2nGe1-IMt34

Endpoint analytics (preview) documentation:- [](https://www.youtube.com/redirect?v=2nGe1-IMt34&event=video_description&redir_token=QUFFLUhqbWRUSTc0Q1RoelVIMVl2ZlZQb2hyeV9TRm1od3xBQ3Jtc0trRHdnRXg1WmdTaXRmZ0h4cng1cEtzYXUtRm5tdWxtMno4WWExZ3hCNnJueEdJVGRsLVFpMHdfZV9SMldhQ3ZGVi1vT1EwQXAwMGdtYmtWVzJiUFpXbUxXdWM2MHdfaTF2RlJSZmduaU5sa2g3Ry1KWQ%3D%3D&q=https%3A%2F%2Fdocs.microsoft.com%2Fen-us%2Fmem%2Fanalytics%2F)[https://docs.microsoft.com/en-us/mem/analytics/](https://docs.microsoft.com/en-us/mem/analytics/)

Tutorial: Proactive remediations:- [](https://www.youtube.com/redirect?v=2nGe1-IMt34&event=video_description&redir_token=QUFFLUhqbjA4eDljcDc3b1hQNzRrMkFyLVNZTE5QVUc3Z3xBQ3Jtc0tuQ2lSWlhyS0k1c2RlMU5ucGtGeWZ1Y1lLd081X2lfZXpldm91ZVdPdWI0YUEwaXUzanlHT0dOWHVFQUM1MHJESGNPWWdUQlFXcWZsaERlcHg4R2N1RFBFZEZSX0VJNW1fMzg2WWhBUV9WUjIxWHlvbw%3D%3D&q=https%3A%2F%2Fdocs.microsoft.com%2Fen-us%2Fmem%2Fanalytics%2Fproactive-remediations)[https://docs.microsoft.com/en-us/mem/analytics/proactive-remediations](https://docs.microsoft.com/en-us/mem/analytics/proactive-remediations)

Scripts used in this tutorial:- 
[https://github.com/byteben/Windows-10/blob/master/Detect\_EnableAutomaticUpdates.ps1](https://github.com/byteben/Windows-10/blob/master/Detect_EnableAutomaticUpdates.ps1)  
[https://github.com/byteben/Windows-10/blob/master/EnableAutomaticUpdates.ps1](https://github.com/byteben/Windows-10/blob/master/EnableAutomaticUpdates.ps1)

Clients require access to the following URLs to be able to send Telemetry Data to Intune:-

Intune Managed Devices:- 
[https://\*.events.data.microsoft.com](https://www.youtube.com/redirect?v=2nGe1-IMt34&event=video_description&redir_token=QUFFLUhqbHVmQ0FVVldjLWpaRWhZbUNvajZXcEJfbC1WZ3xBQ3Jtc0tsUTRuXzJGV1ZjdHNkWXpERHFfMWZQVm1vS2Q5bHVZSFdYdHdiTUtaeFJkLUx6bmFScU1UWkQ4YXEwR214QV9SQi1ETDBxSTJBSzNIbEFBOWpRd21tRFNXZFEzb1lEOHhYaHliNHZkSDdIMHVOZWtOaw%3D%3D&q=https%3A%2F%2F%2A.events.data.microsoft.com)

Configuration Manager Managed Clients:- 
[https://graph.windows.net](https://www.youtube.com/redirect?v=2nGe1-IMt34&event=video_description&redir_token=QUFFLUhqbk9KcEF0T1BHbmotMU5IcThFclBKLVQtWEJ2d3xBQ3Jtc0ttaTQtOV9ZcmQ4LUZ4cThabmtJVUpIM1RWcWJzbnlzbkRWY2ltZ2xrUnBmQTR3NkFpUS02aVJoSTcwRm1kQVBVVTdqNjNVb2NmczRjWU9EUjVkcjlJV0lTbGpTWEdlWmtSNEU0MUIyQWNxZTRjTlJBZw%3D%3D&q=https%3A%2F%2Fgraph.windows.net)  
[https://\*.manage.microsoft.com](https://www.youtube.com/redirect?v=2nGe1-IMt34&event=video_description&redir_token=QUFFLUhqbW5XUmdiMlVaZmw2UVQyWlR5WDE4TlFYazFFd3xBQ3Jtc0tsZEtnblRFZFFIOTJKRDZXeGtJSGplclBURWpuQnMySV9wY0lnc3hfSDNwOGcyNDktYzVaV3V3cWVmb3ptYWRNMlRhWHdFdk04cXJjbGMtZkdicmRLNVVZODhBc1ZCcVM3b1hSdUlmUkx5TFI3OGZ6bw%3D%3D&q=https%3A%2F%2F%2A.manage.microsoft.com)

**Script TIP** The PowerShell execution policy on the device can't be set to _Restricted_ or _AllSigned_

3 Real world examples where Proactive Remediations have been used:-

https://byteben.com/bb/using-memcm-to-fix-legacy-gpo-settings-that-prevent-co-managed-clients-getting-updates-from-intune/

https://byteben.com/bb/microsoft-edge-stops-receiving-updates-after-the-windows-update-workload-is-moved-to-intune/

https://byteben.com/bb/office-365-updates-stop-working-when-workloads-are-switched-to-intune