---
title: "Signing PowerShell Scripts for an SCCM App Detection Method"
date: 2018-07-24
tags: ["app-detection", "ca", "code-signing", "configmgr", "pki", "powershell", "sccm", "script"]
categories: ["configmgr-memcm-sccm", "microsoft", "scripts"]
---

In this blog post we will look at signing the PowerShell scripts we use in the "App Detection Method" when distributing apps with ConfigMgr. The PowerShell Execution Policy can be modified in Client Settings to allow ConfigMgr to execute unsigned scripts. If your environment needs to be a bit tighter with script execution and you dont want to open up the Execution Policy, here is how you can sign the scripts using your own PKI infrastructure.

<!--more-->

In the following example, we will be distributing the OneDrive client. The PowerShell we use in the "App Detection Method" will check the OneDrive version, if it exists, for the current logged on user.

Big shout to [@nickolajA](https://twitter.com/nickolaja?lang=en) for making his OneDrive file version detection script availble to the community here [http://www.scconfigmgr.com/2016/05/24/deploy-onedrive-next-generation-sync-client-with-configmgr/](http://www.scconfigmgr.com/2016/05/24/deploy-onedrive-next-generation-sync-client-with-configmgr/)

### Here is what we will cover

1\. Create a custom Code Signing Template on your CA

2\. Complete a Certificate Request using the Code Signing Template

3\. Export the Code Signing Certificate

4\. Distribute the Code Signing Certificate via GPO

5\. Signing the PowerShell Script

### Create a custom Code Signing Template on your CA

The first task will be to create a new Code Signing Template on your CA. If we use the out of the box template on the CA, the subject of the issued certificate will be the user who requests it. I like to use a general name for the code signing certificate. It looks tidier and i dont end up plastering my username in all my clients Trusted Publisher stores.

1\. On your CA, open the Certificate Authority MMC (Start - Run - certsrv.msc)

2\. Expand your CA, right click "Certificate Templates" and click "Manage"

![](http://byteben.com/bb/images/2018/07/certsrv-msc.jpg)

3\. Find the Template "Code Signing", right click it and choose "Duplicate Template"

![](http://byteben.com/bb/images/2018/07/cert-templates.jpg)

4\. Give the new Template a name

![](http://byteben.com/bb/images/2018/07/cert-templates-templatename.jpg)

5\. Add the user who will sign the scripts and set their permission to "Enroll"

![](http://byteben.com/bb/images/2018/07/cert-templates-security.jpg)

6\. Click the "Subject Name" tab and choose the radio option "Supply in the request".

![](http://byteben.com/bb/images/2018/07/cert-templates-subjectname.jpg)

You may be presented with a warning:-

_"Current settings for this certificate template allow a client to submit a certificate request using any subject name and does not require approval by a certificate manager. Combining these certificate options may create a security risk and is not recommended."_

If you want to overcome the security risk, have the CA certificate manager approve any certificate request made of this template. More on this can be found at [https://blogs.technet.microsoft.com/pki/2011/03/08/ca-manager-approval-required-for-certificate-re-enrollment/](https://blogs.technet.microsoft.com/pki/2011/03/08/ca-manager-approval-required-for-certificate-re-enrollment/) but essentially you can choose to require "CA certificate manager approval" from the "Issuance Requirements" tab.

![](http://byteben.com/bb/images/2018/07/cert-templates-camanagerapproval.jpg)

If you select CA Manager Approval, you will need to approve the certificate request from the "Pending Requests" folder in your certsrv.msc console. We will not be covering CA certificate manager approval in this post.

7\. Go back to certsvc.msc console, right click "Certificate Templates" and choose "New - Certificate Template to Issue"

![](http://byteben.com/bb/images/2018/07/cert-templates-templatetoissue.jpg)

8\. Choose the template we just created and click "Ok"

### Complete a Certificate Request using the Code Signing Template

9\. From your computer, launch MMC as the user you specified would enroll the Code Signing certificate in Step 5

10\. Add the  "Certificate Snap-in for the Current User"

![](http://byteben.com/bb/images/2018/07/cert-request.jpg)

11\. Expand "Certificates - Current User". Right click "Peronal" and choose "All Tasks - Request New Certificate"

![](http://byteben.com/bb/images/2018/07/cert-request-new.jpg)

12\. Click "Next"

13\. Highlight "Active Directory Enrollment Policy" and click "Next"

![](http://byteben.com/bb/images/2018/07/cert-request-adenrollmentpolicy.jpg)

14\. In the "Request Certificates" window, select the template you created in Step 4

![](http://byteben.com/bb/images/2018/07/cert-request-adenrollmentpolicy-select.jpg)

15\. You will need to provide a subject name so go ahead and click the "Properties" button

16\. With the "Subject" tab highlighted, change the "Subject Name: Type" from "Full DN" to "Common name". Enter a value (remember this is the certificate name that will appear in your clients Trusted publishers store after we push out the Certificate with GPO). In this example we used "ConfigAdminCodeSigning". Press the "Add >" button.

![](http://byteben.com/bb/images/2018/07/cert-request-adenrollmentpolicy-subject.jpg)

17\. Click "Ok"

18\. Click "Enroll"

![](http://byteben.com/bb/images/2018/07/cert-request-adenrollmentpolicy-enroll.jpg)

19\. Click "Finish"

![](http://byteben.com/bb/images/2018/07/cert-request-adenrollmentpolicy-enrollfinish.jpg)

20\. You will see your new Code Signing Certificate in the Current User's Personal Store, with the generic name you specified, when the template requested a subject, in Step 16

### Export the Code Signing Certificate

Now we have our Code Signing Certificate, we need to export it to our clients. In this section we will export the Certificate and Publish it to our clients using GPO

21\. No more GUI, lets do some PowerShell. Open PowerShell as the same user you specified in Step 5 (The Code Signing certificate is in their Personal Store).

22\. Lets use the Get-ChildItem cmdlet to view our Code Signing certificate in the Personal store

```
Get-ChildItem Cert:\CurrentUser\my -CodeSigningCert
```

![](http://byteben.com/bb/images/2018/07/cert-pshell-getchilditem.jpg)

Assuming you only have the one Code Signing certificate in the Personal store, it will appear as above.

23\. The following article shows us how to export the certificate in a DER format.

[https://docs.microsoft.com/en-us/powershell/module/pkiclient/export-certificate?view=win10-ps](https://docs.microsoft.com/en-us/powershell/module/pkiclient/export-certificate?view=win10-ps)

We set a variable called $Cert to use for the Export-Certificate cmdlet

```
$cert = (Get-ChildItem -Path cert:\CurrentUser\My\589337BE00308546B611D456969B339FB155E400
```

Where "589337BE00308546B611D456969B339FB155E400" is the Thumbprint of the Code Signing Certificate (yours will be different).

![](http://byteben.com/bb/images/2018/07/cert-pshell-certvariable.jpg)

24\. Lets export the DER Certificate (You will need the PKI PowerShell module installed to do this - it is on your CA Server by default)

```
Export-Certificate -Cert $cert -FilePath c:\certs\ConfigAdminCodeSigning.cer
```

![](http://byteben.com/bb/images/2018/07/cert-pshell-exportedcer.jpg)

### Distribute the Code Signing Certificate via GPO

25\. Open the "Group Policy Management" console (gpmc.msc)

26\. Right click the "Group Policy Objects" folder and click "New" (You can edit an existing Policy if you prefer)

![](http://byteben.com/bb/images/2018/07/cert-gpo-new.jpg)

27\. Call the new policy "Code\_Signing\_Trusted\_Publisher"

28\. Link and Enable the policy to your client computers OU

29\. Richt click the new policy and choose "Edit"

30\. Expand "Computer Configuration - Policies - Windows Settings - Security Settings - Public Key Policies - Trusted Publishers"

![](http://byteben.com/bb/images/2018/07/cert-gpo-trustedpublisher.jpg)

31\. Right click "Trusted Publishers" and choose "Import"

32\. Click "Next" and "Browse" to the location where you exported the Certificate in Step 24

33\. Select the DER file and click "Open"

![](http://byteben.com/bb/images/2018/07/cert-gpo-trustedpublisher-open.jpg)

34\. Click Next, ensuring the "Trusted Publishers" store is selected

![](http://byteben.com/bb/images/2018/07/cert-gpo-trustedpublisher-select.jpg)

35\. Click "Finish"

You should now see the Certificate in the "Trusted Publishers" Public Key Policy

![](http://byteben.com/bb/images/2018/07/cert-gpo-trustedpublisher-final.jpg)

This certificate will make its way to your clients and the next Group Policy refresh interval. Ensure the Certificate is deployed before you start signing and distributing your PowerShell scripts (see below)

### Signing the PowerShell Script

Now we can start signing our scripts. We have the signing certificate in the Current User (as specified in Step 9) Personal store, this user will sign the scripts and the clients should have the matching Code Signing DER (.cer) certificate in their Local Machine "Trusted Publisher" store.

For the sake of the example below, create a folder in the root called "PS1" e.g. C:\\PS1 - This is where we will put the PowerShell scripts we want to sign.

Everytime you modify the script, you will have to re-sign in it. For that reason, i create a copy of the script I want to sign. For example, the script I want to sign is called "check-onedriveversion.ps1". I create a copy of this file and name it "check-onedriveversion\_signed.ps1". It is the later file that I will sign - leaving the original script unchanged.

![](http://byteben.com/bb/images/2018/07/cert-sign-unsignedps1.jpg)

Again I want to thank @NickolaJ for sharing his File Version Check script at [http://www.scconfigmgr.com/2016/05/24/deploy-onedrive-next-generation-sync-client-with-configmgr/](http://www.scconfigmgr.com/2016/05/24/deploy-onedrive-next-generation-sync-client-with-configmgr/)

36\. Launch PowerShell as the user we identified in Step 9, on the same computer (this is where the code signing certificate is).

37\. We will use the Set-AuthenticodeSignature cmdlet to sign the script. Lets declare $cert again as we did in Step 23

```
$cert = (Get-ChildItem -Path cert:\CurrentUser\My\589337BE00308546B611D456969B339FB155E400
```

Where "589337BE00308546B611D456969B339FB155E400" is the Thumbprint of the Code Signing Certificate (yours will be different).

38\. We will then use this variable with the Set-AuthenticationcodeSignature cmdlet

```
Set-AuthenticodeSignature -Certificate $cert -FilePath C:\PS1\check-onedriveversion_signed.ps1
```

![](http://byteben.com/bb/images/2018/07/cert-sign-setauthenticationcodesignature.jpg)

39\. Examine your folder, the signed scripts will be large because they contain the signature block

![](http://byteben.com/bb/images/2018/07/cert-sign-ps1.jpg)

40\. Open the Script to view the signature block (do not modify the file or the signature will be invalidated)

![](http://byteben.com/bb/images/2018/07/cert-sign-signatureblock.jpg)

Thats it. You can now use the script in your SCCM App Detection Method. No more error 0x87D00327 (as per below)

![](http://byteben.com/bb/images/2018/07/script-not-signed.jpg)

To check the app detection script is working, view **appdiscovery.log** on the client

This is what the log file would have shown if your scripts were not signed and the clients Execution Policy expected allowed execution of signed scripts only.

![](http://byteben.com/bb/images/2018/07/appdiscovery-error-1024x55.jpg)

The **appdiscovery.log** should now show successful execution of the App Detection Method

![](http://byteben.com/bb/images/2018/07/appdiscovery-success-1024x55.jpg)