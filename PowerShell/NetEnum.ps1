# Network enumeration and information gathering
# Liam Powell


Param($Interface, $Conn, [switch]$Help, [switch]$Verbose, [switch]$Colorblind, $Out)

function GlobalSettings{
    $global:ErrorActionPreference="SilentlyContinue"
    $global:BadColor = 'Red'
    $global:GoodColor = 'Green'
    if($Colorblind){
        $global:BadColor = 'Magenta'
        $global:GoodColor = 'Cyan'
    }
}

function Gather{

    if($Interface){
        $Adapter = Get-CimInstance Win32_NetworkAdapterConfiguration | ? Description -match $Interface 
    }else{
        $Adapter = Get-CimInstance Win32_NetworkAdapterConfiguration 
    }
    foreach($x in $Adapter){
        if(!$Conn){
            if($Out){
                Write-Host "Writing to $out..." -ForegroundColor $GoodColor
                echo "<-----$x----->" >> $Out
            }else{
                Write-Host "<-----$x----->" -ForegroundColor $GoodColor
            }
            if($Out){
                ft -InputObject $x -Property Description, IPAddress, IPSubnet, DefaultIPGateway, DNSHostName, DNSServerSearchOrder -AutoSize >> $Out
                }else{
                    ft -InputObject $x -Property Description, IPAddress, IPSubnet, DefaultIPGateway, DNSHostName, DNSServerSearchOrder -AutoSize
                }
            if($Out){
                Write-Host "Writing Connections"
                echo "<-----Connections----->" >> $Out
            }else{
                Write-Host "<-----Connections----->"
            }
            try{
                $Connections = Get-NetTCPConnection -LocalAddress $x.IPAddress[0]
                if($Out){
                    ft -InputObject $Connections -Property LocalAddress, LocalPort, RemoteAddress, RemotePort, OwningProcess -AutoSize >> $Out
                    }else{
                        ft -InputObject $Connections -Property LocalAddress, LocalPort, RemoteAddress, RemotePort, OwningProcess -AutoSize
                    }
                if($Verbose){
                    try{
                        $DNSList=@()
                        if($Out){
                            Write-Host "Writing DNS Names"
                            echo " <-----Resolving DNS Names----->" >> $Out
                        }else{
                            Write-Host "<-----Resolving DNS Names----->"
                        }
                        foreach($x in $connections){
                            $IsDNS = Resolve-DNSName $x.RemoteAddress
                            if($IsDNS){
                                $DNSList += $IsDNS
                            }
                        }
                        if($Out){
                            ft -InputObject $DNSList -Property Name, Server, Type >> $Out
                            }else{
                                ft -InputObject $DNSList -Property Name, Server, Type
                            }
                    }catch{

                    }
                    try{
                        $TestPort =@()
                        if($Out){
                            Write-Host "Writing Connection Test"
                            echo "<-----Testing Connections----->" >> $Out
                        }else{
                            Write-Host "<-----Testing Connections----->"
                        }
                        foreach($x in $connections){
                            $strx = (Out-String -InputObject $x.RemoteAddress).Trim()
                            $TestPort += Get-CimInstance Win32_PingStatus -filter "Address='$strx' AND Timeout=1000"
                        }
                        if($Out){
                            ft -InputObject $TestPort -Property Address, IPV4Address, IPV6Address, ResponseTime, StatusCode -AutoSize >> $Out
                            Write-Host "Report generated!"
                            }else{
                                ft -InputObject $TestPort -Property Address, IPV4Address, IPV6Address, ResponseTime, StatusCode -AutoSize
                            }
                        }catch{

                        }
                }
                }catch{
                    echo "No connections on $x"
                    Write-Host
                }
            }
    }
    if($Conn){
        $Connections = Get-NetTCPConnection | ? RemoteAddress -eq $Conn
        $Adapter = Get-CimInstance Win32_NetworkAdapterConfiguration | ? IPAddress -match $Connections.LocalAddress 
        if($Adapter){
            if($out){
                echo "<----- $Adapter ----->">> $out
                ft -InputObject $Adapter -Property Description, IPAddress, IPSubnet, DefaultIPGateway, DNSHostName, DNSServerSearchOrder -AutoSize >> $Out
                echo "<----- Connections ----->">> $out
            }else{
                Write-Host "<----- $Adapter ----->" -ForegroundColor $GoodColor
                ft -InputObject $Adapter -Property Description, IPAddress, IPSubnet, DefaultIPGateway, DNSHostName, DNSServerSearchOrder -AutoSize
                Write-Host "<----- Connections ----->"
            }
            foreach($x in $Connections){
                if($out){
                    ft -InputObject $Connections -Property LocalAddress, LocalPort, RemoteAddress, RemotePort, OwningProcess -AutoSize >> $Out
                }else{
                    ft -InputObject $Connections -Property LocalAddress, LocalPort, RemoteAddress, RemotePort, OwningProcess -AutoSize
                }
            }
        }

    }



}

if($help){
    Write-Host "Simple network adapter analysis tool"
    Write-Host 
    Write-Host "NetEnum <command>"
    Write-Host
    write-host "Commands"
    Write-Host "    -Verbose            Get DNS Resolution and connection testing."
    Write-Host "    -Interface          Specify interface to analyze."
    Write-Host "    -Conn               Search adapters by remote address connection."
    Write-Host "    -Out                Direct output to file."
    Write-Host "    -Colorblind         Friendly color options."
    Write-Host
    exit
}
GlobalSettings
Gather