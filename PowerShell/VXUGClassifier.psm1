# Stolen from VXUnderground
# Thanks smelly

Function Classify{
<#
    .SYNOPSIS
        Use MpCmdRun.exe to classify malware samples in any provided directory. Shamelessly stolen from VXUnderground. See the OG at https://x.com/vxunderground/status/1835141032121389477.

    .EXAMPLE 
        Classify -Path "C:\Path\To\Some\Directory\Or\File" -Excludes "SubDirectories,ToExclude" -Rename -UpdateSignatures

        This is probably what you want. It will look at all files within the given Path (excluding Excludes) and rename all detected threats to the threat name via MpCmdRun. It will also update sigs before running. Use -Verbose to see errors and additional information.
    .PARAMETER Path
        The path of the directory or file to scan. 
    .PARAMETER Excludes
        Sub directories to exclude from the search.
    .PARAMETER Rename
        A switch param to rename all files to their threat name.
    .PARAMETER UpdateSignatures
        Updates the signatures in MpCmdRun before scanning files. 
#>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true,ValueFromPipeline=$True)]
        $Path,
        [Parameter(Mandatory=$false,ValueFromPipeline=$True)]
        $Excludes,
        [Parameter(Mandatory=$false,ValueFromPipeline=$false)]
        [switch]
        $Rename,
        [Parameter(Mandatory=$false,ValueFromPipeline=$false)]
        [switch]
        $UpdateSignatures
    )
if($UpdateSignatures){
."C:\Program Files\Windows Defender\MpCmdRun.exe" -SignatureUpdate
}
$Stats = [psobject]@{
    "Files Scanned" = 0
    "Threats" = 0
    "Completion Time" = [System.Diagnostics.Stopwatch]::startNew()
}
foreach($malware in (Get-ChildItem -Exclude $Excludes -Path $Path | Get-ChildItem -Recurse)){
    [int]$Stats.'Files Scanned' += 1
    Try{
        # If a file is open or is an archive or other un-hashable file with GFH, skip item
        $Hash = (Get-FileHash -Algorithm SHA256 -Path $malware.FullName -ErrorAction Stop).Hash
        $Threat = "$($(."C:\Program Files\Windows Defender\MpCmdRun.exe" -Scan -ScanType 3 -File "$($malware.FullName)" -DisableRemediation).Split("`n")[6].Split(": ")[1])-$Hash".Replace("/",".").Replace(":",".").Replace("!",".")
        [int]$Stats.Threats += 1
        Write-Host "Threat Detected: $Threat"   -ForeGroundColor Green
        if($Rename){
            Rename-Item -Path $malware.FullName -NewName $Threat
            Write-Host "File Renamed: $malware -> $Threat"
        }
    }Catch{
        switch ($_.FullyQualifiedErrorId) {
            # We don't need to print every file without a detected threat
            "InvokeMethodOnNull" { continue }
            # Catch and print hash issues. Usually an archive or file lock problem.
            "UnauthorizedAccessError,Microsoft.PowerShell.Commands.GetFileHashCommand" { Write-Verbose "ERROR: $($_.FullyQualifiedErrorId) File cannot be hashed. File likely locked or not hashable." }
            # Weird random issues print more info. 
            Default { Write-Verbose "ERROR: $($_.FullyQualifiedErrorId)`n$($_.Exception)" }
        }
    }
}
$Stats.'Completion Time'.Stop()
$Stats.'Completion Time' = $Stats.'Completion Time'.Elapsed.TotalSeconds
$Stats
}
Export-ModuleMember -Function Classify
