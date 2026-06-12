---
title: "Mitel/PrairyieFyre Contact Center Client 5.8 Silent Install"
date: 2012-09-29
tags: ["mitel", "mitel-contactcentre-prairiefyre", "scripts-2"]
categories: ["mitel", "mitel-contactcentre-pfyre", "scripts"]
---

Rolling out Windows 7 64bit prompted me to create an installation script for our PrairieFyre Contact Center Client. It is fairly basic, we install some prerequisites, the Contact Center Client (CCC) with the IP address of the server and then do a bit of cleaning up (vcredist is so messy and dumps its installation files into the root...blah). Ok, first of all we need to extract all the necessary setup files onto our server share.

<!--more-->The CCC software is normall available by browsing to the CCMWeb website installed on your Contact Server.

[![Mitel-PrairyieFyre-Contact-Center-Client 58-Silent-Install](/images/2012/09/Mitel-PrairyieFyre-Contact-Center-Client-58-Silent-Install-150x150.jpg "Mitel-PrairyieFyre-Contact-Center-Client 58-Silent-Install")](http://byteben.com/bb/images/2012/09/Mitel-PrairyieFyre-Contact-Center-Client-58-Silent-Install.jpg)

You can find the same client software by browsing to "%ProgramFiles%\\prairieFyre Software Inc\\CCM\\Websites\\CCMWeb\\downloads\\client\_setup.exe". This is a self extracting archive, unzip it to your desired installation point. We will refer to this installation point as "\\\\servername\\share".. The script I created follows:-

```
"\\servername\share\vcredist_x86 2005\vcredist_x86.exe" /q
"\\servername\share\vcredist_x86 2005 RTM\vcredist_x86.exe" /q
"\\servername\share\vcredist2008_x86\vcredist_x86.exe" /q
msiexec /qn /i "\\servername\share\WSE3_0\Microsoft WSE 3.0 Runtime.msi"
msiexec /qn /i "\\servername\share\msxml6\msxml6.msi"
msiexec /qn /i "\\servername\share\Client Component Pack.msi" ENTERPRISEIPADDRESS=127.0.0.1 IPADDRESSTOTEST=http://127.0.0.1/CCMWeb/WebForms/ClientTest.aspx
del /q /f C:\eula.1028.txt
del /q /f C:\eula.1031.txt
del /q /f C:\eula.1033.txt
del /q /f C:\eula.1036.txt
del /q /f C:\eula.1040.txt
del /q /f C:\eula.1041.txt
del /q /f C:\eula.1042.txt
del /q /f C:\eula.2052.txt
del /q /f C:\eula.3082.txt
del /q /f C:\globdata.ini
del /q /f C:\install.exe
del /q /f C:\install.ini
del /q /f C:\install.res.1028.dll
del /q /f C:\install.res.1031.dll
del /q /f C:\install.res.1033.dll
del /q /f C:\install.res.1036.dll
del /q /f C:\install.res.1040.dll
del /q /f C:\install.res.1041.dll
del /q /f C:\install.res.1042.dll
del /q /f C:\install.res.2052.dll
del /q /f C:\install.res.3082.dll
del /q /f C:\VC_RED.cab
del /q /f C:\VC_RED.MSI
del /q /f C:\vcredist.bmp
```

Obviously replace the 127.0.0.1 IP address with the IP address of your CCM Server. Simple really, not really much more need saying on the subject. I haven't looked into the vcredist install to find out why it does that dirty dump in the root each time, maybe one day when the rain falls and I have nothing to do Ill look into it.

Hope it helps :)

## Mitel/PrairyieFyre Contact Center Client 5.8 Silent Install

### Mitel/PrairyieFyre Contact Center Client 5.8 Silent Install