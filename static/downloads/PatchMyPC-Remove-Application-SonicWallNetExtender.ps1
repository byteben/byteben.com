<#
.SYNOPSIS
    Remove a specified application
.DESCRIPTION
    This script will remove an application based on the provided application name and publisher name. The script scans the registry for a matching ProductName and Vendor name, then uses the information found in the registry to uninstall the application.
.PARAMETER AppToUninstall
    Specify the application name to target as it is shown in Add/Remove Programs (Programs and Features). Supports Wildcards (*). This parameter is required.
.PARAMETER PublisherToUninstall
    Specify the publisher name to target as it is shown in Add/Remove Programs (Programs and Features). Supports Wildcards (*). This parameter is required.
.PARAMETER VersionToUninstall
    Specify a specific Major or Minor version number to target. Wildcards are supported. EX: 14.* would only target major version 14, or 14.1.* would only target major version 14 and minor version 1. This is not required and defaults to "*"."
.PARAMETER SilentUninstallArgument
    If targeting an EXE uninstallation where a QuietUninstallString is not specified in the registry, provide a SilentUninstallArgument. Failure to provide this argument for an EXE installation may result in failure to remove the application.
.EXAMPLE
    PS C:\> PatchMyPC-Remove-Application.ps1 -AppToUninstall "GPL Ghostscript" -PublisherToUninstall "Artifex Software Inc." -SilentUninstallArgument "/S"
    Silently uninstall GPL Ghostscript by Artifex Software Inc. from the device using the argument "/S" on the uninstall string found in the registry
.NOTES
    Patch My PC - Version 1.1
#>

[CmdletBinding()]
param (
    [Parameter()]
    [String]
    $AppToUninstall = "SonicWall NetExtender",
    [Parameter()]
    [String]
    $PublisherToUninstall = "Sonicwall Inc.",
    [Parameter()]
    [String]
    $VersionToUninstall = "*",
    [Parameter()]
    [String]
    $SilentUninstallArgument = ""
)
begin {
    #Set log  path desired if you want to change simply change the loglocation parameter to a folder path the log will alwyays be the name of the script.
    Function Get-InstSoftware {
        if ([IntPtr]::Size -eq 4) {
            $regpath = 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*'
        }
        else {
            $regpath = @(
                'HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*'
                'HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*'
            )
        }
        Get-ItemProperty $regpath | . { process {
                if ($_.DisplayName -and $_.UninstallString) {
                    $_ 
                } 
            } } | Select-Object DisplayName, QuietUninstallString, UninstallString, PSChildName, Publisher, InstallDate, DisplayVersion | Sort-Object DisplayName
    }
    
    Function Start-TSxLog {
        #Set global variable for the write-TSxInstallLog function in this session or script.
        [CmdletBinding()]
        param (
            #[ValidateScript({ Split-Path $_ -Parent | Test-Path })]
            [string]$FilePath
        )
        try {
            if (!(Split-Path $FilePath -Parent | Test-Path)) {
                New-Item (Split-Path $FilePath -Parent) -Type Directory | Out-Null
            }
            #Confirm the provided destination for logging exists if it doesn't then create it.
            if (!(Test-Path $FilePath)) {
                ## Create the log file destination if it doesn't exist.
                New-Item $FilePath -Type File | Out-Null
            }
            ## Set the global variable to be used as the FilePath for all subsequent write-TSxInstallLog
            ## calls in this session
            $global:ScriptLogFilePath = $FilePath
        }
        catch {
            #In event of an error write an exception
            Write-Error $_.Exception.Message
        }
    }

    Function Write-TSxLog {
        #Write the log file if the global variable is set
        param (
            [Parameter(Mandatory = $true)]
            [string]$Message,
            [Parameter()]
            [ValidateSet(1, 2, 3)]
            [string]$LogLevel = 1,
            [Parameter(Mandatory = $false)]
            [bool]$writetoscreen = $true   
        )
        $TimeGenerated = "$(Get-Date -Format HH:mm:ss).$((Get-Date).Millisecond)+000"
        $Line = '<![LOG[{0}]LOG]!><time="{1}" date="{2}" component="{3}" context="" type="{4}" thread="" file="">'
        $LineFormat = $Message, $TimeGenerated, (Get-Date -Format MM-dd-yyyy), "$($MyInvocation.ScriptName | Split-Path -Leaf):$($MyInvocation.ScriptLineNumber)", $LogLevel
        $Line = $Line -f $LineFormat
        Add-Content -Value $Line -Path $ScriptLogFilePath
        if ($writetoscreen) {
            switch ($LogLevel) {
                '1' {
                    Write-Verbose -Message $Message
                }
                '2' {
                    Write-Warning -Message $Message
                }
                '3' {
                    Write-Error -Message $Message
                }
                Default {
                }
            }
        }
        if ($writetolistbox -eq $true) {
            $result1.Items.Add("$Message")
        }
    }

    function set-TSxDefaultLogPath {
        #Function to set the default log path if something is put in the field then it is sent somewhere else. 
        [CmdletBinding()]
        param
        (
            [parameter(Mandatory = $false)]
            [bool]$defaultLogLocation = $true,
            [parameter(Mandatory = $false)]
            [string]$LogLocation
        )
        if ($defaultLogLocation) {
            $LogPath = Split-Path $script:MyInvocation.MyCommand.Path
            $LogFile = "$($($script:MyInvocation.MyCommand.Name).Substring(0,$($script:MyInvocation.MyCommand.Name).Length-4)).log"     
            Start-TSxLog -FilePath $($LogPath + "\" + $LogFile)
        }
        else {
            $LogPath = $LogLocation
            $LogFile = "$($($script:MyInvocation.MyCommand.Name).Substring(0,$($script:MyInvocation.MyCommand.Name).Length-4)).log"     
            Start-TSxLog -FilePath $($LogPath + "\" + $LogFile)
        }
    }

}
process {
    set-TSxDefaultLogPath -defaultLogLocation:$false -LogLocation $ENV:TEMP
    $Software = Get-InstSoftware | Where-Object { ($_.DisplayName -like $AppToUninstall) -and ($_.DisplayVersion -like $VersionToUninstall) -and ($_.Publisher -like $PublisherToUninstall) }
    Write-TSxLog -Message "Starting log for $AppToUninstall removal for Patch My PC"
    If ($Software -eq $null) {
        Exit 0
    }
    Else {    
        foreach ($Install in $Software) {
            if ($install.UninstallString -like "msiexec*") {
                Write-TSxLog -Message "Now removing $($Install.DisplayName) using command $($Install.PSChildName)"
                Write-TSxLog -Message "Now building the MSI arguments for start process"
                $MSIArguments = @(
                    '/x'
                    $Install.PSChildName
                    '/qn'    
                    '/L*v "C:\Windows\Temp\PatchMyPC-' + $($Install.DisplayName) + '.log"'
                    'REBOOT=REALLYSUPPRESS'
                )
                Write-TSxLog -Message "Now submitting the following arguments to start-process using MSIExec.exe $($MSIArguments)"
                try {
                    $Results = Start-Process "msiexec.exe" -ArgumentList $MSIArguments -Wait -NoNewWindow -ErrorAction Stop -PassThru
                    Write-TSxLog -Message "The application was uninstalled with Exit Code: $($Results.ExitCode)"
                }
                catch {
                    Write-TSxLog -Message "An error occured trying to remove a version of the software it terminated with the error $($_.Exception.Message)" -LogLevel 3
                    Write-TSxLog -Message "The Exit code was $($Results.ExitCode)"
                }
                Write-TSxLog -Message "The application has been succesfully removed"
            } else {
                if ($install.QuietUninstallString) {
                    Write-TSxLog -Message "Now removing $($Install.DisplayName) using Quiet Uninstall String: $($Install.QuietUninstallString)"
                    try {
                        $Results = Start-Process $Install.QuietUninstallString -Wait -NoNewWindow -ErrorAction Stop -PassThru
                        Write-TSxLog -Message "The application was uninstalled with Exit Code: $($Results.ExitCode)"
                    }
                    catch {
                        Write-TSxLog -Message "An error occured trying to remove a version of the software it terminated with the error $($_.Exception.Message)" -LogLevel 3
                        Write-TSxLog -Message "The Exit code was $($Results.ExitCode)"
                    }
                } else {
                    Write-TSxLog -Message "Now removing $($Install.DisplayName) using command $($Install.UninstallString) $SilentUninstallArgument"
                    try {
                        $Results = Start-Process $Install.UninstallString -ArgumentList $SilentUninstallArgument -Wait -NoNewWindow -ErrorAction Stop -PassThru
                        Write-TSxLog -Message "The application was uninstalled with Exit Code: $($Results.ExitCode)"
                    }
                    catch {
                        Write-TSxLog -Message "An error occured trying to remove a version of the software it terminated with the error $($_.Exception.Message)" -LogLevel 3
                        Write-TSxLog -Message "The Exit code was $($Results.ExitCode)"
                    }

                }
                
            }
        }
    }
}
