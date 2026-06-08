---
title: "Update Compliance - Checking client prerequisites"
date: 2022-01-03
tags: ["compliance", "endpoint-analytics", "mempowered", "msintune", "reporting"]
categories: ["intune", "microsoft", "scripts", "windows-10"]
---

# Background

Before you can begin to process Update Compliance data from your devices, you must first ensure that they meet the requirements to participate in the Update Compliance process. Update Compliance uses Windows client diagnostic data for **all** of its reporting. It collects data for update deployment progress, [Windows Update for Business](https://docs.microsoft.com/en-us/windows/deployment/update/waas-manage-updates-wufb) configuration data, and Delivery Optimization usage data. Collected data is sent to a customer-owned [Azure Log Analytics](https://docs.microsoft.com/en-us/azure/log-analytics/query-language/get-started-analytics-portal) workspace.

<!--more-->

Sometimes we observe discrepancies with actual vs expected Log Analytics Data. This can often be because the client is failing to meet the prerequisites to collect or send its diagnostic data. The aim of this post is to help you identify the reason(s) why your devices may not be sending telemetry in the expected way.

**TL;DR** The [Check-UpdateComplianceSettings.ps1](https://github.com/MSEndpointMgr/Intune/blob/master/Montoring/Update%20Compliance/Check-UpdateComplianceSetting.ps1) script in this post will check that the device meets the prerequisites to send diagnostic data to Update Compliance. The script is designed to be run as a Proactive Remediation from Intune and is based on a similar script Microsoft provides for Update Compliance health and remediation

The solution outlined in this post is aimed at Intune managed devices. Microsoft do provide a script and some other binaries to check and remediate Update Compliance issues on devices. The Microsoft solution works well but I don't like to deviate from Configuration Profiles if I can help it. IMO, there are already many configuration options in Intune and adding a script with binaries to configure Update Compliance draws me too far away from a position I am comfortable with.

# Client Prerequisites

## Windows 10/11

Update Compliance works only with Windows 10 or Windows 11 - that should be pointed out straight away. If we were to expand on that point, only the Pro, Education and Enterprise SKUs are supported. A compatibility matrix can be found below

<figure>

|  | Windows 10 | Windows 11 | Windows Server | Surface Hub | IoT | Other |
| --- | --- | --- | --- | --- | --- | --- |
| Home | ❌ | ❌ | \- | \- | \- | \- |
| Professional | ✔️ | ✔️ | \- | \- | \- | \- |
| Education | ✔️ | ✔️ | \- | \- | \- | \- |
| Enterprise | ✔️ | ✔️ | \- | \- | \- | \- |
| Enterprise Multi-session | ✔️ | ✔️ | \- | \- | \- | \- |

<figcaption>

Supported OS for Update Compliance

</figcaption>

</figure>

## Required Endpoints

The device must be able to contact certain endpoints for both authentication and sending of diagnostic data. It is important to make consideration for the following endpoints on your proxy or firewall

- https://v10c.events.data.microsoft.com
- https://v10.vortex-win.data.microsoft.com
- https://settings-win.data.microsoft.com
- http://adl.windows.com
- https://watson.telemetry.microsoft.com
- https://oca.telemetry.microsoft.com
- https://login.live.com

## Required Services

It is difficult to single out individual Windows services and dependencies but specific to Update Compliance, the following services are required to be present and healthy

- **wlidsvc** (Microsoft Account Sign-in Assistant)
- **diagtrack** (Connected User Experiences and Telemetry)

## Required Policies

We can now use the Settings Catalog to configure all Update Compliance settings instead of Custom Configuration Profiles

- [**Commer**](https://docs.microsoft.com/en-us/windows/client-management/mdm/dmclient-csp#provider-providerid-commercialid)**[c](https://docs.microsoft.com/en-us/windows/client-management/mdm/dmclient-csp#provider-providerid-commercialid)**[**ialID**](https://docs.microsoft.com/en-us/windows/client-management/mdm/dmclient-csp#provider-providerid-commercialid)
- [**AllowTelemetry**](https://docs.microsoft.com/en-us/windows/client-management/mdm/policy-csp-system#system-allowtelemetry)
- [**ConfigureTelemetryOptInSettingsUx**](https://docs.microsoft.com/en-us/windows/client-management/mdm/policy-csp-system#system-configuretelemetryoptinsettingsux)
- [**AllowDeviceNameInDiagnosticData**](https://docs.microsoft.com/en-us/windows/client-management/mdm/policy-csp-system#system-allowdevicenameindiagnosticdata)
- [**AllowUpdateComplianceProcessing**](https://docs.microsoft.com/en-us/windows/client-management/mdm/policy-csp-system#system-allowUpdateComplianceProcessing)

<figure>

![](/images/2021/12/UpdateCompliance_SettingsCatalog.jpg)

<figcaption>

Settings Catalog

</figcaption>

</figure>

## Required Windows Configuration

Other information that is required to be present and healthy for the device to process and send diagnostics for Update Compliance

- **SQMID** The Windows SQM (Software Quality Metrics) device identifier
- **UTC CSP** The Win32CompatibilityAppraiser configuration service provider

# Solution

[Check-UpdateComplianceSettings.ps1](https://github.com/MSEndpointMgr/Intune/blob/master/Montoring/Update%20Compliance/Check-UpdateComplianceSetting.ps1) is a script designed to be deployed as a pre-remediation detection script using a Proactive Remediations in Endpoint Analytics.

The script must be run in the SYSTEM context

When creating the Proactive Remediation, ensure you select to run as 64-bit PowerShell

<figure>

![](/images/2021/12/image-11.png)

<figcaption>

Run script in 64-bit PowerShell

</figcaption>

</figure>

The script will check the following conditions on the device

- CheckSqmID
- CheckCommercialId
- CheckTelemetryOptIn
- CheckConnectivityURL(s)
- CheckUtcCsp
- CheckDiagtrackDLLVersion
- CheckDiagtrackService
- CheckMSAService
- CheckAllowDeviceNameInTelemetry
- CheckAllowUpdateComplianceProcessing
- CheckAllowWUfBCloudProcessing
- CheckConfigureTelemetryOptInChangeNotification
- CheckConfigureTelemetryOptInSettingsUx

If some conditions do not **PASS** the tests successfully a hard fail is recorded and the pre-remediation detection script will exit with a code of 1 (Fail) and the failure(s) will be listed in the pre-remediation detection output column

<figure>

![](/images/2021/12/image-3-1024x285.png)

<figcaption>

Failed test results are displayed

</figcaption>

</figure>

If all tests **PASS** successfully, **OK** will be listed in the pre-remediation detection output column

<figure>

![](/images/2021/12/image-5.png)

<figcaption>

If all tests pass OK is displayed

</figcaption>

</figure>

## Interactive Option

You can view more detailed information if you run the script interactively on a client. You may wish to do this while troubleshooting an issue.

The script needs to be run in 64 bit PowerShell and in the SYSTEM context. You can achieve this by using PSEXEC (64bit) included in [PSTools](https://docs.microsoft.com/en-us/sysinternals/downloads/psexec) from Sysinternals

```
psexec64 -s -i C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe
```

<figure>

![](/images/2021/12/image-6.png)

<figcaption>

Running 64bit PowerShell as SYSTEM

</figcaption>

</figure>

The script accepts 2 parameters

- Detailed - This option outputs the results in a table
- ExportJSON - This option outputs the results as a JSON.

<figure>

![](/images/2021/12/image-7.png)

<figcaption>

No parameter passed

</figcaption>

</figure>

<figure>

![](/images/2021/12/image-13.png)

<figcaption>

Detailed parameter passed

</figcaption>

</figure>

<figure>

![](/images/2021/12/image-9.png)

<figcaption>

Export-JSON parameter passed

</figcaption>

</figure>

## Next Steps

We intend to ingest the device Update Compliance health into Log Analytics so we can compare any Update Compliance reporting anomalies with the last successful **OK** health status of the device from the proactive remediation.

Proactive Remediations are very versatile. This solution doesn't contain a remediation script but we can see how powerful it can be just to collect information for inventory and troubleshooting.

Reach out if you need help, Ben.