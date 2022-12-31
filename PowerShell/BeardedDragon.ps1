param($Name, $Device, $Competition, [switch]$help, [switch]$version)

# Help menu
function help(){
    Write-host "BeardedDragon"
    Write-Host "Windows enumeration script that generates an HTML report"
    Write-Host "Example Usage`n`n`t.\BeardedDragon.ps1 -Name `"Liam Powell`" -Device `"2012 Active Directory`" -Competition `"Regionals`"`n"
    Write-Host "Usage:"
    Write-Host "`t-Name`n`t`tName of report author"
    Write-Host "`tDevice`n`t`tName of the device"
    Write-Host "`tCompetition`n`t`tCompetition level"
    Write-Host "`tHelp`n`t`tDisplay this help menu`n"
}

function GlobalOptions(){
    $global:ErrorActionPreference="SilentlyContinue"
}

function CreateDirectory(){
    # Create the site directrory 
    if(get-item -Path Site){
        return
    }
    New-Item -Path Site -ItemType Directory
}

function CreateBackup(){
    # Create the site backup
    Write-Progress -Activity "Zipping Site..."
    Compress-Archive -Path .\Site\ -DestinationPath .\"Enum-Backup-$(Get-Date -Format "MM-dd-yyyy_HH_mm")"
    Write-Progress -Completed True
}

function GatherInfo(){
    # Load Info together, its slooooooooooooowwwwwwwwwwwwwww
    Write-Progress -Activity "Gathering Device Information..."
    $global:DeviceInfo = Get-CimInstance CIM_ComputerSystem 
    $global:DeviceFeatures = Get-WindowsFeature | Where Installed | Select-Object DisplayName, Name, Path, Description | ConvertTo-HTML -Fragment -As Table
    Write-Progress -Activity "Gathering Process Information..."
    $global:ProcessInformation = Get-CimInstance Win32_Process | Select-Object ProcessName, Path, CreationDate, CommandLine | ConvertTo-HTML -Fragment -As Table
    Write-Progress -Activity "Gather Service Information..."
    $global:ServiceInformation = Get-CimInstance Win32_Service | Select-Object Name, PathName, Caption, Description, State | ConvertTo-HTML -Fragment -As Table
    Write-Progress -Activity "Gathering Local Account Information..."
    $global:LocalUser = Get-LocalUser | Select-Object Name, Enabled, LastLogon, PasswordRequired, Description, SID | ConvertTo-HTML -Fragment
    $global:LocalGroup = Get-LocalGroup | Select-Object Name, Description, SID | ConvertTo-HTML -Fragment
    Write-Progress -Activity "Gathering Scheduled Task Information..."
    $global:ScheduledTasks = Get-ScheduledTask |Select-Object TaskName, Author, State, Description, TaskPath | ConvertTo-HTML -Fragment -As Table
    Write-Progress -Activity "Gathering Networking Information..." 
    $global:NetEstablished = Get-NetTCPConnection | ? State -eq "Established" | Select-Object LocalAddress, LocalPort, RemoteAddress, RemotePort, OwningProcess, CreationTime | ConvertTo-HTML -Fragment -As Table
    $global:NetListen = Get-NetTCPConnection | ? State -eq "Listen" | Select-Object LocalAddress, LocalPort, RemoteAddress, RemotePort, OwningProcess, CreationTime | ConvertTo-HTML -Fragment -As Table
    $global:NetFull = Get-NetTCPConnection | Select-Object State, LocalAddress, LocalPort, RemoteAddress, RemotePort, OwningProcess, CreationTime | ConvertTo-HTML -Fragment -As Table
    
    # Could this be a single array? Yes.
    if(Get-WindowsFeature -Name AD-Domain-Services | ? Installed){
        $global:ActiveDirectory = $True
        Write-Progress -Activity "Gathering Active Directory Information..."
        $global:ActiveDirectoryDomain = get-addomain | Select Forest, InfrastructureMaster, NetBIOSName, DomainMode, DomainSID| ConvertTo-HTML -Fragment -As Table
        $global:ActiveDirectoryUser = LocalGet-ADUser | ConvertTo-HTML -Fragment -As Table
        $global:ActiveDirectoryComputer = get-adcomputer -Filter * | Select Name, DistinguishedName, DNSHostName, Enabled, SID | ConvertTo-HTML -Fragment -As Table
        $global:ActiveDirectoryGroup = get-adgroup -Filter * | Select Name, DistinguishedName, GroupCategory, GroupScope, SID | ConvertTo-HTML -Fragment -As Table
        $global:ActiveDirectoryOU = LocalGet-ADOU | ConvertTo-HTML -Fragment -As Table

        # begin weird -Path is not relative for some reason fix
         $loc = (Get-Location).Path 
        # Idk why this still isn't working. It just hates being put with the other files ig.
        # write-host "where is this going tho fr"
        # $locc = $loc+"\Site\GPO.html"
        # Get-GPOReport -All -ReportType HTML -Path $locc
        # write-host "$loc\Site\GPO.html"
        # Write-Host $locc
        # literally doesn't work even when hardcoded why
        # Get-GPOReport -All -ReportType HTML -Path C:\Users\Administrator\Documents\GitHub\BeardedDragon\Site\GPO.html
        # $locc = $loc+"\Site"

        # Screw PS, I do what I want
        Invoke-Command -ScriptBlock {Get-GPOReport -All -ReportType HTML -Path $loc\GPO.html}
	#Out-File -InputObject $a -FilePath Site\GPO.html
        
    }else{
        $global:ActiveDirectory = $False
    }

    # IIS
    if(Get-WindowsFeature -Name Web-Server | ? Installed){
        $global:IIS = $True
        $global:IISSites = Get-WebSiteInfo | ConvertTo-HTML -Fragment -As Table
    }

    if(Get-WindowsFeature -Name DNS | ? Installed){
        Write-Progress -Activity "Gathering DNS Information..."
        $global:DNS = $True
        $global:DNSZone = Get-DnsServerZone
    }

    Write-Progress -Completed True
}

Function Get-WebSiteInfo
{
    $WebSite = Get-IISSite | Select-Object -property @{Name='Name';Expression={$_.Name -join '; '}},
                                            @{Name='ID';Expression={$_.ID -join '; '}},
                                            @{Name='State';Expression={$_.State -join '; '}},
                                            @{Name='Bindings';Expression={$_.Bindings -join '; '}}
Return $WebSite
}

Function LocalGet-ADUser{
    $ADOU = Get-ADUser -Filter * | Select-Object -property @{Name='SamAccountName';Expression={$_.SAMAccountName -join '; '}},
                                                                @{Name='Name';Expression={$_.Name -join '; '}},
                                                                @{Name='DistinguishedName';Expression={$_.DistinguishedName -join '; '}},
                                                                @{Name='Enabled';Expression={$_.Enabled -join '; '}},
                                                                @{Name='SID';Expression={$_.SID -join '; '}}
    return $ADOU
}

Function LocalGet-ADOU{
    $ADOU = Get-ADOrganizationalUnit -Filter * | Select-Object -property @{Name='Name';Expression={$_.Name -join '; '}},
                                                                @{Name='DistinguishedName';Expression={$_.DistinguishedName -join '; '}},
                                                                @{Name='LinkedGroupPolicyObjects';Expression={$_.LinkedGroupPolicyObjects -join '; '}},
                                                                @{Name='ObjectGUID';Expression={$_.ObjectGUID -join '; '}}
    return $ADOU
}

function CreateTemplate(){
    # Create the HTML template for the webpages
    if(Get-Item -Path Site\header.html){
        Get-ChildItem Site | %{rm $_.FullName}
    }
    $Header=@'
    <style>
        #Device {position: absolute; top: 2%; left: 2%; padding: 0px 0px;}
        #Author { float: left; padding: 0px 100px; }
        #Device, #Author { display: inline;}
        #Content { float: center; top: %5; clear:both; text-align:center;} 
        a:link { color: #000000;}
        a:visited { color: #000000;}
        h1, h5, th { text-align: center; font-family: Segoe UI;}
        table { margin: auto; font-family: Segoe UI; box-shadow: 10px 10px 5px #888; border: thin ridge grey; }
        th { background: #0046c3; color: #fff; max-width: 400px; padding: 5px 10px; text-wrap:normal; word-wrap:break-word;}
        td { font-size: 11px; padding: 5px 20px; color: #000; max-width: 600px; text-wrap:normal; word-wrap:break-word; }
        tr { background: #b8d1f3; text-wrap:normal; word-wrap:break-word}
        tr:nth-child(even){ background: #dae5f4; text-wrap:normal; word-wrap:break-word;}
        p { text-align: center;}
        .Summary { margin: auto; overflow: hidden;}
        iframe { margin: auto; width: 1200; height: 400; display:block; border: 0px;}
        ul { display: inline-block; text-align: left;}
    </style>

'@ +"    <h1> Enumeration Started $(Get-Date) </h1>"
    Out-File -InputObject $Header -FilePath Site\header.html
}

function CreateNavigation(){
    # Role based navigation menu
    # Infinitely expandable by filtering features and adding before closing statement
    $NavStart = @"
    <table style=`"font-color: #000000;`">
        <tr>
            <th>
                <a href =`"Index.html`"> Home </a>
            </th>
            <th>
                <a href=`"Processes.html`"> Processes </a>
            </th>
            <th>
                <a href=`"Services.html`"> Services </a>
            </th>
            <th>
                <a href=`"Local.html`"> Local Accounts </a>
            </th>
            <th>
                <a href=`"Tasks.html`"> Tasks </a>
            </th>
            <th>
                <a href=`"Network.html`"> Network </a>
            </th> 
"@
    if($ActiveDirectory){
        $ActiveDirectoryInject = @"
            <th>
                <a href=`"ActiveDirectory.html`"> Active Directory </a>
            </th>
            <th>
                <a href=`"GPO.html`" target="_blank"> Group Policy </a>
            </th>
"@
        $NavStart += $ActiveDirectoryInject
    }
    if($IIS){
        $IISInject = @"
            <th>
                <a href=`"IIS.html`"> IIS </a>
            </th>
"@
        $NavStart += $IISInject
    }
    if($DNS){
        $DNsInject = @"
            <th>
                <a href=`"DNS.html`"> DNS </a>
            </th>
"@
        $NavStart += $DNsInject
    }
    $NavStart += @"

        </tr>
    </table>
"@
    Add-Content -Value $NavStart -Path Site\header.html
}

function CreateAuthorBlock(){
    # Create the author and device info block
    $AuthBlock = @"
    <!--
        Author: {0} 
        Device: {1} 
        Competition: {2} 
    -->
    <div id=Device>
        <h4> Device Name: {3} </h4>
        <h4> Domain: {4} </h4>
        <h4> User: {5} </h4>
    </div>
"@ -f $Name, $Device, $Competition, $DeviceInfo.Name, $DeviceInfo.Domain, $env:UserName
    Add-Content -Value $AuthBlock -Path Site\header.html
}

function GenerateReport(){
# Create the report
    $Header = Get-Content -Path Site\header.html -Raw
    $HTMLStart = @"
    <!DOCTYPE html>
    <HTML>
        <head>
        {0}
        </head>
        <body>
            <div id=Content>
                <h1 id="title">
                <script>
                    var fileName = location.href.split("/").slice(-1); 
                    var out = String(fileName).split(".");
                    document.getElementById("title").innerHTML = out[0];
                </script>
"@ -f $header
    $HTMLEnd = @"
                </h1>
            </div>
        </body>
    </HTML>
"@

    # Create Process Information Page
    Out-File -InputObject $HTMLStart -FilePath Site\Processes.html
    Add-Content -Value $ProcessInformation -Path Site\Processes.html
    Add-Content -Value $HTMLEnd -Path Site\Processes.html

    # Create Service Information Page
    Out-File -InputObject $HTMLStart -FilePath Site\Services.html
    Add-Content -Value $ServiceInformation -Path Site\Services.html
    Add-Content -Value $HTMLEnd -Path Site\Services.html

    # Create Local Account Information Page
    Out-File -InputObject $HTMLStart -FilePath Site\Local.html
    Add-Content -Value $LocalUSer -Path Site\Local.html
    Add-Content -Value "<h1> Groups </h1>" -Path Site\Local.html
    Add-Content -Value $LocalGroup -Path Site\Local.html
    Add-Content -Value $HTMLEnd -Path Site\Local.html

    # Create Scheduled Task Information Page
    Out-File -InputObject $HTMLStart -FilePath Site\Tasks.html
    Add-Content -Value $ScheduledTasks -Path Site\Tasks.html
    Add-Content -Value $HTMLEnd -Path Site\Tasks.html

    # Create Network Information Page
    Out-File -InputObject $HTMLStart -FilePath Site\Network.html
    Add-Content -Value "<h1> Established </h1>" -Path Site\Network.html
    Add-Content -Value $NetEstablished -Path Site\Network.html
    Add-Content -Value "<h1> Listening </h1>" -Path Site\Network.html
    Add-Content -Value $NetListen -Path Site\Network.html
    Add-Content -Value "<h1> Full </h1>" -Path Site\Network.html
    Add-Content -value $NetFull -Path Site\Network.html
    Add-Content -Value $HTMLEnd -Path Site\Network.html

    if($ActiveDirectory){
    # Create Active Directory Information Page
        Out-File -InputObject $HTMLStart -FilePath Site\ActiveDirectory.html
        Add-Content -Value "<h1> Domain </h1>" -Path Site\ActiveDirectory.html
        Add-Content -Value $ActiveDirectoryDomain -Path Site\ActiveDirectory.html
        Add-Content -Value "<h1> Computers </h1>" -Path Site\ActiveDirectory.html
        Add-Content -Value $ActiveDirectoryComputer -Path Site\ActiveDirectory.html
        Add-Content -Value "<h1> Users </h1>" -Path Site\ActiveDirectory.html
        Add-Content -Value $ActiveDirectoryUser -Path Site\ActiveDirectory.html
        Add-Content -Value "<h1> Organizational Units </h1>" -Path Site\ActiveDirectory.html
        Add-Content -Value $ActiveDirectoryOU -Path Site\ActiveDirectory.html
        Add-Content -Value "<h1> Groups </h1>" -Path Site\ActiveDirectory.html
        Add-Content -Value $ActiveDirectoryGroup -Path Site\ActiveDirectory.html
        Add-Content -Value $HTMLEnd -Path Site\Network.html
    }

    if($IIS){
        # IIS Info
        Out-File -InputObject $HTMLStart -FilePath Site\IIS.html
        Add-Content -Value $IISSites -Path Site\IIS.html
        Add-Content -Value $HTMLEnd -Path Site\IIS.html
    }

    if($DNS){
        # DNS 
        Out-File -InputObject $HTMLStart -FilePAth: Site\DNS.html
        Foreach($x in $DNSZone){
            $DNSOut = Get-DNSServerResourceRecord -ZoneName $x.ZoneName | Select HostName, RecordType, DistinguishedName | ConvertTo-Html -Fragment -As Table
            $DNSName = @"
            <h1> {0} </h1>
"@ -f $x.ZoneName
            Add-Content -Value $DNSName -Path Site\DNS.html
            Add-Content -Value $DNSOut -Path Site\DNS.html
        }
        Add-Content -Value $HTMLEnd -Path Site\DNS.html
    }
# Finish index
# Add to Index example 
<#
    $HTMLStart += $AddedContent
    $HTMLStart += $HTMLEnd
#>

    $HTMLStart += @"

        		<h1> Roles </h1>
					<ul class=myul>
"@
    ForEach($x in ($DeviceInfo | Select-Object -ExpandProperty Roles)){
        $HTMLStart += @"

                    		<li> {0} </li>
"@ -f $x
    }
    $HTMLStart += @"

			 		</ul>
                <h1> Features </h1>
"@
    $HTMLStart += $DeviceFeatures
    $HTMLStart += $HTMLEnd

Out-File -InputObject $HTMLStart -FilePath Site\Index.html
}

# Parse parameters
if($help){
    help
    exit
}
if($version){
    Write-Host "BeardedDragon"
    Write-Host "Version: 1.0.0"
    exit
}

# Script start
GlobalOptions
CreateDirectory
GatherInfo
CreateTemplate
CreateNavigation
CreateAuthorBlock
GenerateReport

# Need to move GPO now, because it takes too long to generate to move it when it's created 
# Tho I'm not sure why it couldn't just be put in the right dir to begin with
# PowerShell ¯\_ (?)_/¯
# Keeping it as an inv-cmd just to be safe too 
# lol this still isn't working
# Update: sometimes it works
Invoke-Command -ScriptBlock {Copy-Item -Path $loc\GPO.html -Destination $loc\Site\GPO.html}
CreateBackup

# Open Index
start Site\Index.html