param([switch]$help, [switch]$Backup, [switch]$Compare)

function GlobalSettings{
    $global:ErrorActionPreference="SilentlyContinue"
}

function GenerateBackups{
    # Make backup "clean" list
    if(-Not (Get-Item taskBackup.csv)){
        Get-ScheduledTask | Export-Csv taskBackup.csv
    }
    if(-Not (Get-Item procBackup.csv)){
        Get-CimInstance CIM_Process | Export-Csv procBackup.csv
    }
    if(-Not (Get-Item servBackup.csv)){
        Get-Service | Export-Csv servBackup.csv
    }

    # Could do reg, temp, autorun too
}


function CompareFiles{
    # Set Flags
    if(Get-Item taskBackup.csv){
        $TaskFlag = $True
    }
    if(Get-Item servBackup.csv){
        $ServFlag = $True
    }
    if(Get-Item procBackup.csv){
        $ProcFlag = $True
    }

    # Store current 
    $tasks = Get-ScheduledTask
    $service = Get-Service
    $proc = Get-CimInstance CIM_Process

    # Import cycle
    # Adding ft forces it to complete the command before moving on
    if($TaskFlag){
        $import = Import-Csv taskBackup.csv
        Write-Host "Comparing current tasks to default`nImported File <==> Current Tasks"
        Compare-Object $import $tasks -Property TaskName | ft *
    }
    Start-Sleep 1
    if($ProcFlag){
        $import = Import-Csv procBackup.csv
        Write-Host "`nComparing current processes to default`nImported File <==> Current Processes"
        Compare-Object $import $proc -Property Name | ft *
    }
    Start-Sleep 1
    if($ServFlag){
        $import = Import-Csv servBackup.csv
        Write-Host "`nComparing current servics to default`nImported File <==> Current Services"
        Compare-Object $import $service -Property Name | ft *

    }
}

function help{
    Write-Host @"
    Burrow is a PowerShell script that imports csv PowerShell object files and compares the imported object to the current object. 
    Burrow looks for files: taskBackup.csv, procBackup.csv, and servBackup.csv. If the files do not exist, Burrow will create them.
    Burrow has two modes, Compare and Backup. Backup mode will backup a list of each object as an importable csv, and Compare will compare them.
"@
}

# Enable globals
GlobalSettings

# Start script
if($help){
    help
    exit
}
if($Backup){
    GenerateBackups
}elseif($Compare){
    CompareFiles
}else{
    Write-Host "Defaulting to backup creation. If this is not what you wanted, see -Help"
    GenerateBackups
}
