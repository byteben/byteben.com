---
title: "Update a Client Certificate Private Key using Intune Proactive Remediations"
date: 2021-01-15
categories:
  - "Certificates"
  - "Intune"
  - "Microsoft"
  - "Scripts"
  - "Windows 10"
---

It is not unusual to still see 3rd party products being used in Windows 10. Brad Anderson said "Making a big impact starts with making things really simple" when he outlined Microsoft's vision for modern management. I get this completely and agree with the rhetoric but some orgs are still trying to come around to the idea of "Modern" and some die hard admins just won't let go of their tried and tested tech.

<!--more-->

If it wasn't for these "Die hard" admins (picturing Bruce Willis crawling through the cooling ducts of the datacentre) I wouldn't have this blog post - so I guess that's pretty neat. We were asked to deploy the SonicWall Mobile Connect VPN Client on the Window's 10 laptop fleet.

### Background

I wont dwell on the AOVPN solution from SonicWall but I will highlight a requirement which you may find other VPN vendors stipulating for their products too. Part of the SonicWall AOVPN solution required a SonicWall Windows Service to perform the compliance checks configured for the Device Tunnel policy.

[![](/images/2021/01/image-53-1024x247.png)](/images/2021/01/image-53.png)

One of the requirements was the client had to have a valid workstation authentication certificate issued from an internal Certificate Authority. This meant the account running the SonicWall Windows Service needed to be able to read the workstation certificate to see if it was valid.

### Problem

Let's take a look at a typical workstation authentication certificate enrolled from a Certificate Authority.

Launch **certlm.msc** as an Administrator, right click your workstation certificate used for client authentication and select **All Tasks > Manage Private Keys**

[![](/images/2021/01/image-54.png)](/images/2021/01/image-54.png)

Examine the existing access control list for the workstation certificate

[![](/images/2021/01/image-56.png)](/images/2021/01/image-56.png)

There is the problem - the "LOCAL SERVICE" account does not have permissions to READ this certificate > which ultimately means the compliance check will fail when the SonicWall Windows Service tries to read it.

### Solution

The solution is quite simple - don't use 3rd party products (sic). Seriously, we have to give the "LOCAL SERVICE" account READ permissions to the certificate Private Key. We used PowerShell to check the workstation certificate private key and add the correct permission if it was missing. You could add this script as a Win32 app and make it a dependency for the VPN client that you, presumably, will roll out as a Win32 app. In this post, we will show you how you can do it as a proactive remediation - because Proactive Remediations is the new kid on the block and it deserves more love.

### Scripts

**[Set\_PrivateKeyPermission](https://github.com/byteben/Windows-10/blob/master/Certificates/Set_PrivateKeyPermission.ps1)[.ps1](https://github.com/byteben/Windows-10/blob/master/Certificates/Set_PrivateKeyPermission.ps1)** can be used to add/change an account permission on a certificates private key when the certificate has been issued using a specific template.  
The following 3 parameters are passed to the script: -

**Template** - Specify the name of the template used to issue the certificate  
**Account** - Specify the account you wish to add/change on the private key ACL. The default account will be set to "LOCAL SERVICE" if no parameter is specified  
**Permission** - Specify the permission you would like to set. Choose "Read" or "FullControl"

**Example**  
Set\_PrivateKeyPermission.ps1 -Account "LOCAL SERVICE" -Permission "Read" -Template "Workstation Authentication"

```
<#	
===========================================================================
	 Created on:   	14/01/2021 23:06
	 Created by:   	Ben Whitmore
	 Organization: 	-
	 Filename:     	Set_PrivateKeyPermission.ps1
	 Target System: Windows 10 Only
===========================================================================

1.0 
Release

.SYNOPSIS
The purpose of the script is to change the Private Key Permission on a computer certificate issued from a specific template.

.DESCRIPTION
This script can be used to add/change an account permissions on a certificates private key when the certificate has been issued using a specific template.

.Parameter Template
Specify the name of the template used to issue the certificate

.Parameter Account
Specify the account you wish to add/change on the private key ACL. The default account will be set to "LOCAL SERVICE" if no parameter is specified

.Parameter Permission
Specify the permission you would like to set. Choose "Read" or "FullControl"

.Example
Set_PrivateKeyPermission.ps1 -Account "LOCAL SERVICE" -Permission "Read" -Template "Workstation Authentication EAP-TLS"
#>

Param
(
    [Parameter(Mandatory = $False)]
    [String]$Template = "Workstation Authentication",
    [String]$Account = "LOCAL SERVICE",
    [ValidateSet("Read", "FullControl")]
    [String]$Permission = "Read"
)

#Get Client Certificate issued from the specified Template
$Certificates = Get-ChildItem Cert:\LocalMachine\my |  Where-Object { $_.HasPrivateKey } | Where-Object { $_.Extensions | Where-Object { ($_.oid.friendlyname -match "Certificate Template Information" -and ($_.Format(0) -like "*$($Template)*")) } }

#Change private key perms on Client Certificates
ForEach ($Cert in $Certificates) {
        
    #Get the key
    $Key = [System.Security.Cryptography.X509Certificates.RSACertificateExtensions]::GetRSAPrivateKey($Cert)

    Try {
        #Get the permissions from the key
        $KeyPerm = $Key.key.UniqueName
        $KeyLocation = Get-ChildItem "$env:ALLUSERSPROFILE\Microsoft\Crypto" -Recurse | Where-Object { $_.Name -like "$KeyPerm*" }
        $KeyPermACL = Get-Acl -Path $KeyLocation.FullName
            
        #Check if the Account has the correct Permission on the Private Key
        $ACLAccess = $keypermacl | Select-Object -ExpandProperty AccessToString
    }
    Catch {

        #Catch error if permissions were unobtainable
        Write-Warning "Could not get the ACL: $($error[0].Exception)"
    }

    If ($ACLAccess -like "*$($Account) Allow $($Permission)*") {
        Write-Output """$($Account)"" has the correct ""$($Permission)"" permission on the Certificate Private Key"
    }
    else {
        Write-Warning """$($Account)"" does not have the correct ""$($Permission)"" permission on the Certificate Private Key"
        Write-Output "Setting Private Key Permission to ""$($Permission)"" for Account ""$($Account)""..."
        Try {

            #Create a new permission
            $NewPerm = New-Object security.accesscontrol.filesystemaccessrule $Account, $Permission, Allow

            #Add the new permission to the ACL
            $KeyPermACL.AddAccessRule($NewPerm)
            Set-Acl -Path $KeyLocation.FullName -AclObject $KeyPermACL
        }
        Catch {

            #Catch the error
            Write-Warning "Error modifying the private key ACL: $($error[0].Exception)"
        }
    }
}
```

**[Detect\_PrivateKeyPermission](https://github.com/byteben/Windows-10/blob/master/Certificates/Detect_PrivateKeyPermission.ps1)[.ps1](https://github.com/byteben/Windows-10/blob/master/Certificates/Set_PrivateKeyPermission.ps1)** can be used to verify an account permissions on a certificates private key when the certificate has been issued using a specific template.  
The following 3 parameters are passed to the script: -

**Template** - Specify the name of the template used to issue the certificate  
**Account** - Specify the account you wish to check exists on the private key ACL. The default account will be set to "LOCAL SERVICE" if no parameter is specified  
**Permission** - Specify the permission you would like to check. Choose "Read" or "FullControl"

**Example**  
Detect\_PrivateKeyPermission.ps1 -Account "LOCAL SERVICE" -Permission "Read" -Template "Workstation Authentication"

```
Param
(
    [Parameter(Mandatory = $False)]
    [String]$Template = "Workstation Authentication",
    [String]$Account = "LOCAL SERVICE",
    [ValidateSet("Read", "FullControl")]
    [String]$Permission = "Read"
)

#Get Client Certificate issued from the specified Template
$Certificates = Get-ChildItem Cert:\LocalMachine\my |  Where-Object { $_.HasPrivateKey } | Where-Object { $_.Extensions | Where-Object { ($_.oid.friendlyname -match "Certificate Template Information" -and ($_.Format(0) -like "*$($Template)*")) } }

#Change private key perms on Client Certificates
ForEach ($Cert in $Certificates) {
        
    #Get the key
    $Key = [System.Security.Cryptography.X509Certificates.RSACertificateExtensions]::GetRSAPrivateKey($Cert)

    Try {
        #Get the permissions from the key
        $KeyPerm = $Key.key.UniqueName
        $KeyLocation = Get-ChildItem "$env:ALLUSERSPROFILE\Microsoft\Crypto" -Recurse | Where-Object { $_.Name -like "$KeyPerm*" }
        $KeyPermACL = Get-Acl -Path $KeyLocation.FullName
            
        #Check if the Account has the correct Permission on the Private Key
        $ACLAccess = $keypermacl | Select-Object -ExpandProperty AccessToString
    }
    Catch {

        #Catch error if permissions were unobtainable
        Write-Warning "Could not get the ACL: $($error[0].Exception)"
        Exit 1
    }

    If ($ACLAccess -like "*$($Account) Allow $($Permission)*") {
        Write-Output """$($Account)"" has the correct ""$($Permission)"" permission on the Certificate Private Key"
        Exit 0
    }
    else {
        Write-Warning """$($Account)"" does not have the correct ""$($Permission)"" permission on the Certificate Private Key"
        Exit 1
    }
}
```

### Testing the Scripts

I open **certlm.msc** on one of my clients and examine the ACL on the private key for a certificate issued using the **Workstation Authentication** template

[![](/images/2021/01/image-57.png)](/images/2021/01/image-57.png)

Run **Detect\_PrivateKeyPermission.ps1** on the same client. Remember, if we don't specify any parameters the defaults are passed: -

Account = "LOCAL SERVICE"  
Permission = "Read"  
Template = "Workstation Authentication"

[![](/images/2021/01/image-72.png)](/images/2021/01/image-72.png)

Run **Set\_PrivateKeyPermission.ps1** using the same parameters

[![](/images/2021/01/image-73.png)](/images/2021/01/image-73.png)

and check the private key has been updated

[![](/images/2021/01/image-60.png)](/images/2021/01/image-60.png)

Run **Set\_PrivateKeyPermission.ps1** and specify a new permission e.g. **\-Permission "FullControl"**

[![](/images/2021/01/image-61.png)](/images/2021/01/image-61.png)

and check the private key has been updated again

[![](/images/2021/01/image-62.png)](/images/2021/01/image-62.png)

### Proactive Remediations

  
1 . Visit **[https://endpoint.microsoft.com](https://endpoint.microsoft.com/) > Reports > Endpoint Analytics**

2 . Under Reports, click **Proactive remediations**

3 . Click **Create Script Package**

4 . Enter a Name **Set Certificate Private Key Permission for LOCAL SERVICE**

5 . Click **Next**

6 . Upload both the **Detect\_PrivateKeyPermission.ps1** (Detection Script) and **Set\_PrivateKeyPermission.ps1** (Remediation Script) scripts

[![](/images/2021/01/image-63.png)](/images/2021/01/image-63.png)

7 . Click **Next**

8 . **Assign** the **Custom Script** to your group and select a suitable schedule

[![](/images/2021/01/image-64.png)](/images/2021/01/image-64.png)

9 . Click **Next** and then **Create**

10 . Wait for (or force) a Policy Sync on your clients  
**intunemanagementextension://syncapp**  
(Thanks [@okieselb](https://twitter.com/okieselb) [Triggering Intune Management Extension (IME) Sync](https://oliverkieselbach.com/2020/11/03/triggering-intune-management-extension-ime-sync/))

11 . Monitor the **IntuneManagementExtension.log** on the client located in C:\\ProgramData\\Microsoft\\IntuneManagementExtension\\Logs\\**IntuneManagementExtension.log**

Health Script found

[![](/images/2021/01/image-65.png)](/images/2021/01/image-65.png)

Scripts execute

[![](/images/2021/01/image-66.png)](/images/2021/01/image-66.png)

Scripts in the C:\\Windows\\IMECache folder

[![](/images/2021/01/image-67.png)](/images/2021/01/image-67.png)

Permission not found on the ACL (Exit Code 1) means the remediation script will execute

[![](/images/2021/01/image-68.png)](/images/2021/01/image-68.png)

Remediation successful

[![](/images/2021/01/image-69.png)](/images/2021/01/image-69.png)

Check the ACL on the Certificate Private Key

[![](/images/2021/01/image-70.png)](/images/2021/01/image-70.png)

### Summary

In this post we used Intune Proactive Remediations to detect if a permission exists on a certificate private key issued by a specific template. If the permission was not found we remediated the private key ACL using a PowerShell script.

I hope this post has illustrated how flexible Proactive Remediations can be.