---
title: "Install CutePDF Silently on Windows 7 64bit and remove the ASK Toolbar"
date: 2012-09-28
categories:
  - "Landesk"
  - "Landesk Managment Suite"
  - "Scripts"
tags: ["ask-toolbar", "cutepdf", "cutepdf-silent", "landesk", "landesk-managmentsuite", "windows-7-64bit-cutepdf"]
categories: ["landesk", "landesk-managmentsuite", "scripts"]
---

Well, there I was trying to figure out how to create a silent install script for CutePDF on our Windows 7 64bit PCs. After losing a few hairs trying to work out why it wasn't working silently it was because setup was looking for a 32bit installation of ghostscript. Answer?

<!--more--> Install a 32bit version of ghostscript alongside your 64bit version. Here is my silent install script below. Notice how we uninstall the ASK Toolbar using the msi reference point in the registry. This works quite well for us and we run the install script at logon to prevent killing any open instances of Internet Explorer (this pops up after the install displaying the readme file). I have seen a few posts that say if you use the /no3d switch when installing cutewriter the Ask Toolbar wont be installed - this may be true for earlier version but it doesn't work on the latest version.

**Downloads**

Cutepdf available from: [http://www.cutepdf.com/download/CuteWriter.exe](http://www.cutepdf.com/download/CuteWriter.exe "Cute PDF Writer")

Cute 32bit Converter: [http://www.cutepdf.com/download/converter.exe](http://www.cutepdf.com/download/converter.exe "Cute 32bit Converter")

Ghostscript 64bit: [http://downloads.ghostscript.com/public/gs906w64.exe](http://downloads.ghostscript.com/public/gs906w64.exe "GhostScript 64bit")

```
[Code]
```

```
\\servername\share\gs905w64.exe /S
\\servername\share\32bitconverter\setup.exe /s
\\servername\share\CuteWriter.exe /VERYSILENT
TASKKILL /IM iexplore.exe /F
MsiExec.exe /QN /X {86D4B82A-ABED-442A-BE86-96357B70F4FE}
rd "%ALLUSERSPROFILE%\Start Menu\Programs\CutePDF" /S/Q
rd "%ALLUSERSPROFILE%\Start Menu\Programs\Ghostscript" /S/Q
```

I like to remove the Start Menu items to tidy things up a bit on the Users Start Menu.

That's it, simple but effective. We use Landesk Managment Suite to roll out the script silently to users but it would be equally effective in a login script, perhaps also adding some error control to check to see if it is already installed before you begin)

Hope it helps, shout if you want any more info. :)

## Install CutePDF Silently on Windows 7 64bit and remove the ASK Toolbar

### Install CutePDF Silently on Windows 7 64bit and remove the ASK Toolbar