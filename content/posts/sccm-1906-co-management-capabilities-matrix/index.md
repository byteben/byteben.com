---
title: "SCCM 1906 Co-management Capabilities Matrix"
date: 2019-08-18
categories:
  - "ConfigMgr / MEMCM / SCCM"
  - "Microsoft"
  - "Scripts"
tags: ["1906", "bitwise", "capabilities", "co-management", "configmgr", "powershell"]
categories: ["configmgr-memcm-sccm", "microsoft", "scripts"]
---

I am putting together a Co-management deep dive series in the coming weeks (\*\***UPDATE\*\* [Here it is](<https://byteben.com/bb/co-management-series-merging-the-perimeter-part-1-what-is-co-management/ >)**). One of the things that has intrigued me is the "Capabilities" value when looking at Co-management workloads.

<!--more-->

<figure>

[![](/images/2019/08/co-management_capabilities_1.jpg)](/images/2019/08/co-management_capabilities_1.jpg)

<figcaption>

Co-management Capabilities

</figcaption>

</figure>

The values have changed in 1906 and can be found below

| **Capability** | **Workload** |
| --- | --- |
| 1 | No Workloads - Co-management Configured |
| 2 | Compliance Policies |
| 4 | Resource access Policies |
| 8 | Device Configuration |
| 16 | Windows Updates Policies |
| 32 | Endpoint Protection |
| 64 | Client Apps |
| 128 | Office Click-to-Run Apps |

When we start to move workloads to our Pilot Intune Collections or fully to Intune, the capabilities value reflects the combined workloads.

For example, moving client workloads for Compliance Polices and Client Apps will give the client a new co-management capability of 67. But how do we get to this number? 67

**Co-Management Configured (1) + Compliance Policies (2) + Client Apps (64) = 67**  
We have to add 1 to any merged workload (Co-management configured)

#### But all the capabilities on my clients are odd numbers?

I started looking at this late last night and was examining the XML configs in the CI\_DocumentStore table (that is where I found the capability workloads above). The values in the XML all show the workload capability value from the table above +1, so these values look like this

| **Capability** | **Workload** |
| --- | --- |
| 1 | No Workloads - Co-management Configured |
| 3 | Compliance Policies |
| 5 | Resource access Policies |
| 9 | Device Configuration |
| 17 | Windows Updates Policies |
| 33 | Endpoint Protection |
| 65 | Client Apps |
| 129 | Office Click-to-Run Apps |

So how can we easily work out the merged values if each workload already has +1 added to each workload? (Does that sentence even make sense - lol)

After a shout out on Twitter, the awesome @CodyMathis has done some work on this already. I am never one to reinvent the wheel! A bitwise operation can be done on the integers to get the new capabilities. This dude has a degree in Math! Check out his original post here [https://sccmf12twice.com/2019/01/co-management-multiple-pilot-policies/](https://sccmf12twice.com/2019/01/co-management-multiple-pilot-policies/)

So when we look in CoManagementHandler.log and see the values with +1 already added - a bitwise operation could get us to the new merged capability value. Compliance Polices (3) and Client Apps (65) merged would give you 67! Lets see this in PowerShell using the -bor operator

<figure>

[![](/images/2019/08/co-management_capabilities_2.jpg)](/images/2019/08/co-management_capabilities_2.jpg)

<figcaption>

3 -bor 65 = 67!

</figcaption>

</figure>

<figure>

[![](/images/2019/08/co-management_capabilities_3.jpg)](/images/2019/08/co-management_capabilities_3.jpg)

<figcaption>

Co-management capabilities merged on the client

</figcaption>

</figure>

I would encourage you to check out his script. As of today it covers workloads pre-1906 but the Client Apps capability of 65 can be added and the Device Configuration value can be changed to 9. I have a Pull request on the script to reflect the changes in 1906 capabilities (Cody updated the script on 21/8/19 to reflect the changes in SCCM 1906) [https://github.com/CodyMathis123/CM-Ramblings/blob/master/Convert-CoManagementWorkload.ps1](https://github.com/CodyMathis123/CM-Ramblings/blob/master/Convert-CoManagementWorkload.ps1)

#### Summary

You can use the original values at the beginning of this blog to work out the merged capabilities or use the -bor operator and/or Cody's script to work out the merged capabilities that have already had the +1 added to each workload.

More great reading on co-management capabilities can be found here:- [https://techcommunity.microsoft.com/t5/Intune-Customer-Success/Support-Tip-Configuring-workloads-in-a-co-managed-environment/ba-p/707221](https://techcommunity.microsoft.com/t5/Intune-Customer-Success/Support-Tip-Configuring-workloads-in-a-co-managed-environment/ba-p/707221)

For ease of reference, i have used Cody's script to help generate all the possible capabilities for easy lookup reference.

| **Capabilities** | **Workload** |
| --- | --- |
| 1 | None - Co-management Configured |
| 3 | Compliance Policies |
| 5 | Resource access Policies |
| 7 | Resource access Policies |
|  | Compliance Policies |
| 9 | Device Configuration |
| 11 | Device Configuration |
|  | Compliance Policies |
| 13 | Device Configuration |
|  | Resource access Policies |
| 15 | Device Configuration |
|  | Resource access Policies |
|  | Compliance Policies |
| 17 | Windows Updates Policies |
| 19 | Windows Updates Policies |
|  | Compliance Policies |
| 21 | Windows Updates Policies |
|  | Resource access Policies |
| 23 | Windows Updates Policies |
|  | Resource access Policies |
|  | Compliance Policies |
| 25 | Device Configuration |
|  | Windows Updates Policies |
| 27 | Device Configuration |
|  | Windows Updates Policies |
|  | Compliance Policies |
| 29 | Device Configuration |
|  | Windows Updates Policies |
|  | Resource access Policies |
| 31 | Device Configuration |
|  | Windows Updates Policies |
|  | Resource access Policies |
|  | Compliance Policies |
| 33 | Endpoint Protection |
| 35 | Compliance Policies |
|  | Endpoint Protection |
| 37 | Resource access Policies |
|  | Endpoint Protection |
| 39 | Resource access Policies |
|  | Compliance Policies |
|  | Endpoint Protection |
| 41 | Device Configuration |
|  | Endpoint Protection |
| 43 | Device Configuration |
|  | Compliance Policies |
|  | Endpoint Protection |
| 45 | Device Configuration |
|  | Resource access Policies |
|  | Endpoint Protection |
| 47 | Device Configuration |
|  | Resource access Policies |
|  | Compliance Policies |
|  | Endpoint Protection |
| 49 | Windows Updates Policies |
|  | Endpoint Protection |
| 51 | Windows Updates Policies |
|  | Compliance Policies |
|  | Endpoint Protection |
| 53 | Windows Updates Policies |
|  | Resource access Policies |
|  | Endpoint Protection |
| 55 | Windows Updates Policies |
|  | Resource access Policies |
|  | Compliance Policies |
|  | Endpoint Protection |
| 57 | Device Configuration |
|  | Windows Updates Policies |
|  | Endpoint Protection |
| 59 | Device Configuration |
|  | Windows Updates Policies |
|  | Compliance Policies |
|  | Endpoint Protection |
| 61 | Device Configuration |
|  | Windows Updates Policies |
|  | Resource access Policies |
|  | Endpoint Protection |
| 63 | Device Configuration |
|  | Windows Updates Policies |
|  | Resource access Policies |
|  | Compliance Policies |
|  | Endpoint Protection |
| 65 | Client Apps |
| 67 | Client Apps |
|  | Compliance Policies |
| 69 | Client Apps |
|  | Resource access Policies |
| 71 | Client Apps |
|  | Resource access Policies |
|  | Compliance Policies |
| 73 | Client Apps |
|  | Device Configuration |
| 75 | Client Apps |
|  | Device Configuration |
|  | Compliance Policies |
| 77 | Client Apps |
|  | Device Configuration |
|  | Resource access Policies |
| 79 | Client Apps |
|  | Device Configuration |
|  | Resource access Policies |
|  | Compliance Policies |
| 81 | Client Apps |
|  | Windows Updates Policies |
| 83 | Client Apps |
|  | Windows Updates Policies |
|  | Compliance Policies |
| 85 | Client Apps |
|  | Windows Updates Policies |
|  | Resource access Policies |
| 87 | Client Apps |
|  | Windows Updates Policies |
|  | Resource access Policies |
|  | Compliance Policies |
| 89 | Client Apps |
|  | Device Configuration |
|  | Windows Updates Policies |
| 91 | Client Apps |
|  | Device Configuration |
|  | Windows Updates Policies |
|  | Compliance Policies |
| 93 | Client Apps |
|  | Device Configuration |
|  | Windows Updates Policies |
|  | Resource access Policies |
| 95 | Client Apps |
|  | Device Configuration |
|  | Windows Updates Policies |
|  | Resource access Policies |
|  | Compliance Policies |
| 97 | Client Apps |
|  | Endpoint Protection |
| 99 | Client Apps |
|  | Compliance Policies |
|  | Endpoint Protection |
| 101 | Client Apps |
|  | Resource access Policies |
|  | Endpoint Protection |
| 103 | Client Apps |
|  | Resource access Policies |
|  | Compliance Policies |
|  | Endpoint Protection |
| 105 | Client Apps |
|  | Device Configuration |
|  | Endpoint Protection |
| 107 | Client Apps |
|  | Device Configuration |
|  | Compliance Policies |
|  | Endpoint Protection |
| 109 | Client Apps |
|  | Device Configuration |
|  | Resource access Policies |
|  | Endpoint Protection |
| 111 | Client Apps |
|  | Device Configuration |
|  | Resource access Policies |
|  | Compliance Policies |
|  | Endpoint Protection |
| 113 | Client Apps |
|  | Windows Updates Policies |
|  | Endpoint Protection |
| 115 | Client Apps |
|  | Windows Updates Policies |
|  | Compliance Policies |
|  | Endpoint Protection |
| 117 | Client Apps |
|  | Windows Updates Policies |
|  | Resource access Policies |
|  | Endpoint Protection |
| 119 | Client Apps |
|  | Windows Updates Policies |
|  | Resource access Policies |
|  | Compliance Policies |
|  | Endpoint Protection |
| 121 | Client Apps |
|  | Device Configuration |
|  | Windows Updates Policies |
|  | Endpoint Protection |
| 123 | Client Apps |
|  | Device Configuration |
|  | Windows Updates Policies |
|  | Compliance Policies |
|  | Endpoint Protection |
| 125 | Client Apps |
|  | Device Configuration |
|  | Windows Updates Policies |
|  | Resource access Policies |
|  | Endpoint Protection |
| 127 | Client Apps |
|  | Device Configuration |
|  | Windows Updates Policies |
|  | Resource access Policies |
|  | Compliance Policies |
|  | Endpoint Protection |
| 129 | Office Click-to-Run Apps |
| 131 | Office Click-to-Run Apps |
|  | Compliance Policies |
| 133 | Office Click-to-Run Apps |
|  | Resource access Policies |
| 135 | Office Click-to-Run Apps |
|  | Resource access Policies |
|  | Compliance Policies |
| 137 | Device Configuration |
|  | Office Click-to-Run Apps |
| 139 | Device Configuration |
|  | Office Click-to-Run Apps |
|  | Compliance Policies |
| 141 | Device Configuration |
|  | Office Click-to-Run Apps |
|  | Resource access Policies |
| 143 | Device Configuration |
|  | Office Click-to-Run Apps |
|  | Resource access Policies |
|  | Compliance Policies |
| 145 | Office Click-to-Run Apps |
|  | Windows Updates Policies |
| 147 | Office Click-to-Run Apps |
|  | Windows Updates Policies |
|  | Compliance Policies |
| 149 | Office Click-to-Run Apps |
|  | Windows Updates Policies |
|  | Resource access Policies |
| 151 | Office Click-to-Run Apps |
|  | Windows Updates Policies |
|  | Resource access Policies |
|  | Compliance Policies |
| 153 | Device Configuration |
|  | Office Click-to-Run Apps |
|  | Windows Updates Policies |
| 155 | Device Configuration |
|  | Office Click-to-Run Apps |
|  | Windows Updates Policies |
|  | Compliance Policies |
| 157 | Device Configuration |
|  | Office Click-to-Run Apps |
|  | Windows Updates Policies |
|  | Resource access Policies |
| 159 | Device Configuration |
|  | Office Click-to-Run Apps |
|  | Windows Updates Policies |
|  | Resource access Policies |
|  | Compliance Policies |
| 161 | Office Click-to-Run Apps |
|  | Endpoint Protection |
| 163 | Office Click-to-Run Apps |
|  | Compliance Policies |
|  | Endpoint Protection |
| 165 | Office Click-to-Run Apps |
|  | Resource access Policies |
|  | Endpoint Protection |
| 167 | Office Click-to-Run Apps |
|  | Resource access Policies |
|  | Compliance Policies |
|  | Endpoint Protection |
| 169 | Device Configuration |
|  | Office Click-to-Run Apps |
|  | Endpoint Protection |
| 171 | Device Configuration |
|  | Office Click-to-Run Apps |
|  | Compliance Policies |
|  | Endpoint Protection |
| 173 | Device Configuration |
|  | Office Click-to-Run Apps |
|  | Resource access Policies |
|  | Endpoint Protection |
| 175 | Device Configuration |
|  | Office Click-to-Run Apps |
|  | Resource access Policies |
|  | Compliance Policies |
|  | Endpoint Protection |
| 177 | Office Click-to-Run Apps |
|  | Windows Updates Policies |
|  | Endpoint Protection |
| 179 | Office Click-to-Run Apps |
|  | Windows Updates Policies |
|  | Compliance Policies |
|  | Endpoint Protection |
| 181 | Office Click-to-Run Apps |
|  | Windows Updates Policies |
|  | Resource access Policies |
|  | Endpoint Protection |
| 183 | Office Click-to-Run Apps |
|  | Windows Updates Policies |
|  | Resource access Policies |
|  | Compliance Policies |
|  | Endpoint Protection |
| 185 | Device Configuration |
|  | Office Click-to-Run Apps |
|  | Windows Updates Policies |
|  | Endpoint Protection |
| 187 | Device Configuration |
|  | Office Click-to-Run Apps |
|  | Windows Updates Policies |
|  | Compliance Policies |
|  | Endpoint Protection |
| 189 | Device Configuration |
|  | Office Click-to-Run Apps |
|  | Windows Updates Policies |
|  | Resource access Policies |
|  | Endpoint Protection |
| 191 | Device Configuration |
|  | Office Click-to-Run Apps |
|  | Windows Updates Policies |
|  | Resource access Policies |
|  | Compliance Policies |
|  | Endpoint Protection |
| 193 | Client Apps |
|  | Office Click-to-Run Apps |
| 195 | Client Apps |
|  | Office Click-to-Run Apps |
|  | Compliance Policies |
| 197 | Client Apps |
|  | Office Click-to-Run Apps |
|  | Resource access Policies |
| 199 | Client Apps |
|  | Office Click-to-Run Apps |
|  | Resource access Policies |
|  | Compliance Policies |
| 201 | Client Apps |
|  | Device Configuration |
|  | Office Click-to-Run Apps |
| 203 | Client Apps |
|  | Device Configuration |
|  | Office Click-to-Run Apps |
|  | Compliance Policies |
| 205 | Client Apps |
|  | Device Configuration |
|  | Office Click-to-Run Apps |
|  | Resource access Policies |
| 207 | Client Apps |
|  | Device Configuration |
|  | Office Click-to-Run Apps |
|  | Resource access Policies |
|  | Compliance Policies |
| 209 | Client Apps |
|  | Office Click-to-Run Apps |
|  | Windows Updates Policies |
| 211 | Client Apps |
|  | Office Click-to-Run Apps |
|  | Windows Updates Policies |
|  | Compliance Policies |
| 213 | Client Apps |
|  | Office Click-to-Run Apps |
|  | Windows Updates Policies |
|  | Resource access Policies |
| 215 | Client Apps |
|  | Office Click-to-Run Apps |
|  | Windows Updates Policies |
|  | Resource access Policies |
|  | Compliance Policies |
| 217 | Client Apps |
|  | Device Configuration |
|  | Office Click-to-Run Apps |
|  | Windows Updates Policies |
| 219 | Client Apps |
|  | Device Configuration |
|  | Office Click-to-Run Apps |
|  | Windows Updates Policies |
|  | Compliance Policies |
| 221 | Client Apps |
|  | Device Configuration |
|  | Office Click-to-Run Apps |
|  | Windows Updates Policies |
|  | Resource access Policies |
| 223 | Client Apps |
|  | Device Configuration |
|  | Office Click-to-Run Apps |
|  | Windows Updates Policies |
|  | Resource access Policies |
|  | Compliance Policies |
| 225 | Client Apps |
|  | Office Click-to-Run Apps |
|  | Endpoint Protection |
| 227 | Client Apps |
|  | Office Click-to-Run Apps |
|  | Compliance Policies |
|  | Endpoint Protection |
| 229 | Client Apps |
|  | Office Click-to-Run Apps |
|  | Resource access Policies |
|  | Endpoint Protection |
| 231 | Client Apps |
|  | Office Click-to-Run Apps |
|  | Resource access Policies |
|  | Compliance Policies |
|  | Endpoint Protection |
| 233 | Client Apps |
|  | Device Configuration |
|  | Office Click-to-Run Apps |
|  | Endpoint Protection |
| 235 | Client Apps |
|  | Device Configuration |
|  | Office Click-to-Run Apps |
|  | Compliance Policies |
|  | Endpoint Protection |
| 237 | Client Apps |
|  | Device Configuration |
|  | Office Click-to-Run Apps |
|  | Resource access Policies |
|  | Endpoint Protection |
| 239 | Client Apps |
|  | Device Configuration |
|  | Office Click-to-Run Apps |
|  | Resource access Policies |
|  | Compliance Policies |
|  | Endpoint Protection |
| 241 | Client Apps |
|  | Office Click-to-Run Apps |
|  | Windows Updates Policies |
|  | Endpoint Protection |
| 243 | Client Apps |
|  | Office Click-to-Run Apps |
|  | Windows Updates Policies |
|  | Compliance Policies |
|  | Endpoint Protection |
| 245 | Client Apps |
|  | Office Click-to-Run Apps |
|  | Windows Updates Policies |
|  | Resource access Policies |
|  | Endpoint Protection |
| 247 | Client Apps |
|  | Office Click-to-Run Apps |
|  | Windows Updates Policies |
|  | Resource access Policies |
|  | Compliance Policies |
|  | Endpoint Protection |
| 249 | Client Apps |
|  | Device Configuration |
|  | Office Click-to-Run Apps |
|  | Windows Updates Policies |
|  | Endpoint Protection |
| 251 | Client Apps |
|  | Device Configuration |
|  | Office Click-to-Run Apps |
|  | Windows Updates Policies |
|  | Compliance Policies |
|  | Endpoint Protection |
| 253 | Client Apps |
|  | Device Configuration |
|  | Office Click-to-Run Apps |
|  | Windows Updates Policies |
|  | Resource access Policies |
|  | Endpoint Protection |
| 255 | Client Apps |
|  | Device Configuration |
|  | Office Click-to-Run Apps |
|  | Windows Updates Policies |
|  | Resource access Policies |
|  | Compliance Policies |
|  | Endpoint Protection |