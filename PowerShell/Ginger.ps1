function Main{
    Write-Progress -Activity "Preparing Resources" -Status "Getting Processes and Services"
    $Process = get-ciminstance CIM_Process
    $service = get-ciminstance Cim_Service
    Write-Progress -Completed True
    $a = 1
    $b = $Process.Count
    foreach($x in $Process){
        $ProcName = $x.Name
        $ProcID = $x.ProcessID
        $percomp = ($a/$b) * 100
        Write-Progress -Activity "Writing Process Information" -Status "$ProcID - $ProcName    $a/$b" -PercentComplete $percomp
        ProcPrint $x
        try{
            if($service.ProcessID -eq $x.ProcessID){
                $_service = $service | ? ProcessID -eq $x.ProcessID
                Write-Host "`t<----- Services ----->"
                foreach($x in $_service){
                    ServicePrint $x
                }
            }
            }catch{
                $service = $null
            }
            try{
                if(get-nettcpconnection -OwningProcess $x.ProcessID){
                    $Conn = get-nettcpconnection -OwningProcess $x.ProcessID
                    write-host "`t<----- Connections ----->"
                    foreach($x in $conn){
                        ConnPrint $x
                    }
                }
            }catch{
                $Conn = $null
            }
        $a++
    }
    Write-Progress -Activity -Activity "Preparing Resources" -Status "Getting Tasks and Jobs"
    $Tasks = Get-ScheduledTask
    $Jobs = Get-Job
    Write-Progress -Completed True
    Write-host "`n<----- SCHEDULED TASKS ----->`n"
    foreach($x in $Tasks){
        TaskPrint $x
    }
    foreach($x in $Jobs){
        JobPrint $x
    }
    Write-Progress -Activity "Preparing Resources" -Status "Getting Temp Files"
    $usertmp = Get-ChildItem $env:Temp -Recurse | ? Extension -in (".exe",".ps1",".vbs",".vbscript",".bat",".cmd",".msi")
    $wintemp = Get-ChildItem "C:\Windows\Temp" -Recurse | ? Extension -in (".exe",".ps1",".vbs",".vbscript",".bat",".cmd",".msi")
    Write-Progress -Completed True
    write-host "<----- Temp File Enumeration ----->`n"
    ExePrint $usertmp
    ExePrint $wintemp
}

function ProcPrint($Process){
    $ParentPath = get-ciminstance CIM_Process | ? ProcessID -eq $Process.ParentProcessID
    write-host "<-----"$Process.Name"----->`n"
    write-host "`n`tProcess Name:"$Process.Name"`n`tProcess ID:"$Process.ProcessID"`n`tExecutable Path:"$Process.ExecutablePath
    write-host "`n`tPPID Name:"$ParentPath.Name"`n`tPPID:"$Process.ParentProcessID"`n`tPPID Path:"$ParentPath.ExecutablePath"`n"
}

function ServicePrint($Service){
    write-Host "`t`tService Name:"$Service.Name"`n`t`tService State:"$Service.State"`n"
}

function ConnPrint($Conn){
    $dns = Resolve-DNSName $Conn.RemoteAddress
    write-host "`n`t`tLocal Address:"$Conn.LocalAddress":"$Conn.LocalPort
    write-host "`t`tRemote Address:"$Conn.RemoteAddress":"$Conn.RemotePort"`n"
    Write-Host "`t`tDNS Name Host:"$dns.NameHost"`n"
}

function TaskPrint($task){
    write-host "<-----"$Task.TaskName"----->`n"
    write-host "`tName:"$Task.TaskName"`n`tState:"$Task.State"`n`tURI:"$Task.URI"`n"
}

function JobPrint($job){
    write-Host $job
}

function ExePrint($Item){
    echo $Item
}
$global:ErrorActionPreference="SilentlyContinue"
Main