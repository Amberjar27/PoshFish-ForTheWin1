# Ninetails
#
# Silas Powers
#
# This script is for use on Windows machines to change, export, and import firewall rules.
# Test and verify script before use with a non-production environment my code is bad so assume it will brick.
# Tested on Windows Server 2019.
#
# 
#
<#
# 
#    ⠀ ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠙⠻⢿⣛⣋⠉⠉⠉⠉⠉⠒⠲⠤⣤⢾⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
#    ⠀⠀ ⠀⠀⠀⠀⠀⢀⡤⠴⠒⠒⠒⠒⠒⠦⢤⣀⠀⠀⠀⠀⠀⠀⢀⣠⠤⠒⠉⠁⠀⠀⠀⠀⠀⠀⠀⡴⡱⣿⠦⡀⠀⢀⠤⠆⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
#    ⠀⠀⠀ ⠀⠀⢀⡜⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠙⠦⡉⠒⣺⠭⠅⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⡜⡑⠀⡿⠀⠈⠞⠁⡘⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
#    ⠀⠀⠀⠀ ⠀⣸⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⡼⠋⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢠⠎⡰⠁⠸⡇⠀⠀⡀⡰⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
#    ⠀ ⠀⠀⠀⠀⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣰⠋⠀⠀⣀⣠⠄⠒⠈⠀⠀⠀⠀⠀⠀⢠⠏⠀⠁⠉⠀⠈⠛⢥⣠⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
#    ⠀ ⠀⠀⠀⠀⢸⣀⣀⣀⣀⠀⠀⠀⠀⠀⠀⠀⡰⠁⡠⠖⠋⢠⠃⠀⠀⠀⠀⠀⠀⠀⢀⢔⡏⠀⠀⠀⠀⠸⣷⠠⡀⠙⣆⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
#    ⠀ ⠀⣠⠔⠋⠉⠀⠀⠀⠈⠉⠙⠒⠦⣄⡀⢠⢣⠊⠀⠀⢀⠆⠀⠀⠀⢀⠊⠀⢠⢁⡎⡸⠀⠀⠀⠀⠀⠀⠈⠉⠁⠀⠘⢦⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
#    ⠀ ⡼⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠙⡿⣅⠀⠀⠀⡼⠀⠀⢀⡔⠁⠀⣠⡇⡞⢸⠇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠩⣒⠄⠀⠀⠀⠀⠀⠀⠀⠀
#    ⠀ ⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠳⡀⠀⡇⠀⢠⡞⠀⢀⠔⢹⡎⠀⡞⠀⠀⠀⠀⠀⠀⢠⡒⠒⠷⠿⠷⠒⠚⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀
#    ⠀ ⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠙⣄⠇⢀⢻⢃⣴⠁⠀⢨⠇⣸⠁⠀⠀⠀⠀⠀⠀⢸⠉⠲⢤⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
#    ⠀ ⠹⡄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠘⡶⡈⠸⠃⡇⢰⠀⡜⢀⠇⠀⠀⠀⠀⠀⠀⠀⢸⠀⠀⠀⠙⠦⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
#     ⠀⠀⠹⡄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⠀⠑⢄⠀⠀⢳⠀⠀⣸⢁⢆⡼⡡⡞⠀⠀⠀⠀⠀⠀⠀⠀⠈⣇⠀⠀⠀⠀⠈⢣⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀
#     ⠀⠀⣠⠼⣆⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⡄⠀⠀⢣⠀⣼⠰⢠⣇⠮⠞⠋⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠸⡄⠀⠀⠀⠀⠀⠱⡄⠀⠀⠀⠀⠀⠀⠀⠀
#     ⠀⡞⠁⠀⠈⢣⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣗⠲⢤⡀⣃⣷⣡⢷⡖⠂⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡀⢷⢄⠀⠀⠀⠀⠀⠰⡀⠀⠀⠀⠀⠀⠀⠀
#     ⠰⡇⠀⠀⠀⠀⠙⢦⠀⠀⠀⠀⠀⠀⠀⠀⠸⣀⡴⠋⠁⠀⢠⠎⠀⠀⠀⠀⠀⢀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠁⠸⠀⠁⠢⡀⠀⠀⠀⠘⢄⠀⠀⠀⠀⠀⠀
#     ⠀⢧⠀⠀⠀⠀⠀⠀⠑⢦⡀⠀⠀⠀⠀⠀⠀⢻⡀⠀⠀⠀⢸⡠⡶⢀⡜⡰⣡⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⠇⠀⠀⠀⠈⠲⣄⡀⠀⠈⠳⢄⠀⠀⠀⠀
#     ⠀⠘⣆⠀⠀⠀⠀⠀⠀⠀⠙⠢⣄⠀⠀⠀⠀⠀⠳⡄⠀⠀⠘⠁⠗⠃⢿⡟⠙⣿⡈⡄⠀⠀⠀⠀⡄⡀⣰⡟⠀⠀⠀⠀⠀⠀⠈⢯⡑⠢⠄⣀⠑⠢⢀⣀
#     ⠀⠀⠈⢦⡀⠀⠀⠀⠀⠀⠀⠀⠈⢿⠦⣀⠀⠀⠀⠙⢦⠀⠀⠀⠀⠀⠀⡇⠀⠐⢣⢹⡀⠀⡆⣼⣴⠗⡟⠀⠀⠀⠀⠀⠀⠀⠀⠀⢳⡀⠀⠀⠀⠀⠀⠀
#     ⠀⠀⠀⡜⠻⣄⠀⠀⠀⠀⠀⠀⠀⠸⡴⠚⡟⠢⢄⣀⠀⠳⣄⠀⡟⢲⠒⡇⠀⠀⠀⢑⡇⡼⠛⠉⠁⡼⢡⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢳⡀⠀⠀⠀⠀⠀
#     ⠀⠀⢸⠁⠀⠈⠳⣄⠀⠀⠀⠀⠀⠀⢳⡀⢷⠀⠀⠈⠙⠒⠬⣿⣇⣸⡀⡇⠀⠀⢀⠏⢹⠀⠀⠀⣰⠃⠀⠄⠀⠀⠀⠀⠀⠀⠀⠀⠀⡀⣇⠀⠀⠀⠀⠀
#     ⠀⠀⢸⠀⠀⠀⠀⠈⠳⣄⠀⠀⠀⠀⠀⠳⣸⠀⠀⠀⠀⠀⣠⠃⠀⢨⣧⡇⠀⠀⡼⠀⡟⠀⠀⢠⠇⠀⠀⠘⡀⠀⠀⠀⠀⠀⠀⠀⠀⢀⢸⠀⠀⠀⠀⠀
#     ⠀⠀⠈⢧⠀⠀⠀⠀⠀⠈⢳⢦⡀⠀⠀⠀⠙⢆⠀⠀⣀⠔⠁⢀⡠⢛⣿⠀⠀⢰⠃⢀⡇⠀⠀⡞⠀⠀⠀⠀⠹⡢⢀⠀⠀⠀⠀⠀⠀⠘⣼⠀⠀⠀⠀⠀
#     ⠀⠀⠀⠈⢳⡀⠀⠀⠀⠀⠈⢧⠉⣳⣤⣀⠀⠈⠳⣮⡥⠴⠚⠉⠀⢸⡏⠀⢀⡟⡀⢸⠁⠀⢸⠁⠀⠀⠀⠀⠀⠱⡀⠑⢤⡀⠀⠀⠀⠀⠹⡄⠀⠀⠀⠀
#     ⠀⠀⠀⠀⠀⠙⠢⣄⠀⠀⠀⠈⢿⡁⢀⡏⠑⢢⢤⣈⠳⢄⡀⠀⠀⢸⠇⠀⡼⠀⠑⢿⠀⠀⣼⠀⠀⠀⠀⠀⠀⠀⠙⣄⠀⠈⠓⠦⣄⡀⠀⠑⢄⠀⠀⠀
#     ⠀⠀⠀⠀⠀⠀⠀⠀⠙⠲⠤⣀⣀⠙⢼⡀⠀⣿⠀⠈⠉⠓⠻⠶⣄⣸⠀⢠⣧⡀⠀⠈⡇⠀⢸⠈⢲⢄⡀⠀⠀⠀⠀⠈⠳⣄⠀⠀⠀⠈⠉⠐⠒⠓⠄⠀
#     ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠉⡿⢷⡤⣿⢤⠀⠀⠀⠀⢀⡤⣧⣄⣼⣽⣽⠀⠀⢳⠀⠀⢳⡢⠧⠌⠒⠤⢄⣀⡀⠀⠈⠑⠤⢀⣀⣀⠠⠀⠀⠀⠀
#     ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠧⡼⠧⠼⠼⠀⠀⠀⠀⢿⣰⡇⢸⡆⣹⠀⠀⠀⠸⡄⠀⢄⢹⠓⡄⠀⠀⠀⠀⠈⠉⠉⠉⠉⠉⠁⠀⠀⠀⠀⠀⠀
# ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠉⠉⠉⠁⠀⠀⠀⠀⠉⠙⠛⠛⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
#
# Legend has it that NINETALES came into being when nine wizards possessing sacred powers merged into one. 
# This POKéMON is highly intelligent - it can understand human speech.
#
#>



# Hardcoded CCDC AD ports in an array can add more either using the menu or add them here using the same params.
$allowedPorts = @{
    "80" = @{ DisplayName = "HTTP"; Protocols = @("TCP"); Direction = "Outbound" }                  # http
    "443" = @{ DisplayName = "HTTPS"; Protocols = @("TCP"); Direction = "Outbound" }                # https
    "88" = @{ DisplayName = "Kerberos"; Protocols = @("TCP", "UDP"); Direction = "Both" }           # Kerberos
    "53" = @{ DisplayName = "DNS"; Protocols = @("TCP", "UDP"); Direction = "Both" }                # DNS
    "123" = @{ DisplayName = "NTP"; Protocols = @("UDP"); Direction = "Inbound" }                   # NTP
    "389" = @{ DisplayName = "LDAP"; Protocols = @("TCP"); Direction = "Both" }                     # LDAP
    "636" = @{ DisplayName = "LDAPS"; Protocols = @("TCP"); Direction = "Inbound" }                 # LDAPS
    "110" = @{ DisplayName = "POP3"; Protocols = @("TCP"); Direction = "Both" }                     # POP3
    "995" = @{ DisplayName = "POP3s"; Protocols = @("TCP"); Direction = "Both" }                    # POP3s
    "9998" = @{ DisplayName = "Splunk_Forwarder"; Protocols = @("TCP"); Direction = "Outbound" }    # Splunk forwarder
}

# Apply firewall rules using the global array.
function applyFirewallRulesFromList {
    param (
        [string]$port,
        [string[]]$protocols,
        [string]$direction,
        [string]$displayName
    )
    foreach ($protocol in $protocols) {
        if ($direction -eq "Inbound" -or $direction -eq "Both") {
            New-NetFirewallRule -DisplayName "$displayName ($port $protocol)" -Direction Inbound -Protocol $protocol -LocalPort $port -Action Allow -Profile Any
        }
        if ($direction -eq "Outbound" -or $direction -eq "Both") {
            New-NetFirewallRule -DisplayName "$displayName ($port $protocol)" -Direction Outbound -Protocol $protocol -LocalPort $port -Action Allow -Profile Any
        }
    }
}

# 99% of this is to have a progress bar (removing all existing rules)
function removeAllFirewallRules {
    Write-Host "Removing all firewall rules..." -ForegroundColor Yellow
    $rules = Get-NetFirewallRule
    
    if ($rules.Count -eq 0) {
        Write-Host "No firewall rules exist." -ForegroundColor Red
        return
    }

    $totalRules = $rules.Count
    $currentRule = 0
    Write-Progress -PercentComplete 0 -Status "Removing rules" -Activity "Progress"

    foreach ($rule in $rules) {
        Remove-NetFirewallRule -Name $rule.Name
        $currentRule++
        $percentComplete = ($currentRule / $totalRules) * 100
        Write-Progress -PercentComplete $percentComplete -Status "Removing rules" -Activity "$currentRule of $totalRules rules removed"
        
        # Safety sleep for a lot of rules
        Start-Sleep -Milliseconds 50
    }

    Write-Progress -PercentComplete 100 -Status "Done" -Activity "Fiirewall rules removed"
    Write-Host "All rules have been removed." -ForegroundColor Green
}

# Backup existing firewall rules using netsh advfirewall.
function backupRules {
    $timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
    # Home dir for user you are logged onto. 
    # Can update this to another location so long as the dir exists it will not make one.
    $backupFile = "$env:USERPROFILE\firewallRulesBackup_$timestamp.xml"
    Write-Host "Backing up current firewall rules...." -ForegroundColor Yellow
    # Export
    netsh advfirewall export "$backupFile"
    Write-Host "Backup completed: $backupFile" -ForegroundColor Green
}

# Restores using same method.
function restoreRules {
    $backupFiles = Get-ChildItem -Path "$env:USERPROFILE" -Filter "firewallRulesBackup_*.xml" | Sort-Object LastWriteTime -Descending

    if ($backupFiles.Count -eq 0) {
        Write-Host "No backup files found." -ForegroundColor Red
        return
    }

    Write-Host "Available backup files:" -ForegroundColor Yellow
    $backupFiles | ForEach-Object { Write-Host "$($_.Name)" }
    $selectedFile = Read-Host "Enter the name of the XML file to restore"
    $selectedBackup = $backupFiles | Where-Object { $_.Name -eq $selectedFile }

    if ($selectedBackup) {
        $fullPath = $selectedBackup.FullName
        Write-Host "Restoring firewall rules from $fullPath..." -ForegroundColor Yellow

        if (Test-Path $fullPath) {
            # Import
            netsh advfirewall import "`"$fullPath`""
            Write-Host "Restore completed." -ForegroundColor Green
        } else {
            Write-Host "Backup file does not exist or can't be accessed: $fullPath" -ForegroundColor Red
        }
    } else {
        Write-Host "That backup file does not exist. try again." -ForegroundColor Red
    }
}

# List firewall rules
function listActiveFirewallRules {
    Write-Host "Current firewall rules..." -ForegroundColor Yellow
    Get-NetFirewallRule | Where-Object { $_.Enabled -eq $true } | Format-Table DisplayName, Direction, Action
}

# Append allowedPorts
function addPort {
    param (
        [string]$port,
        [string[]]$protocols,
        [string]$direction,
        [string]$displayName
    )
    if (-Not $allowedPorts.ContainsKey($port)) {
        $allowedPorts[$port] = @{ DisplayName = $displayName; Protocols = $protocols; Direction = $direction }
        Write-Host "Added port $port to allowed list." -ForegroundColor Green
    } else {
        Write-Host "Port $port is already in the allowed ports list." -ForegroundColor Yellow
    }
}

# remove stuff from allowedPorts
function removePort {
    param (
        [string]$port
    )
    if ($allowedPorts.ContainsKey($port)) {
        $allowedPorts.Remove($port)
        Write-Host "Removed port $port from the allowed ports list." -ForegroundColor Green
    } else {
        Write-Host "Port $port is not in the allowed ports list." -ForegroundColor Red
    }
}

# Backup allowedPorts (yyep I am using JSON sry)
function exportAllowedPorts {
    $timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
    $defaultDirectory = "$env:USERPROFILE"
    $fileName = "allowedPortsBackup_$timestamp.json"
    $filePath = Join-Path $defaultDirectory $fileName

    $exportData = $allowedPorts.GetEnumerator() | ForEach-Object {
        @{
            Port = $_.Key
            DisplayName = $_.Value.DisplayName
            Direction = $_.Value.Direction
            Protocols = $_.Value.Protocols
        }
    }

    $exportData | ConvertTo-Json -Depth 10 | Set-Content -Path $filePath
    Write-Host "Allowed ports exported to $filePath" -ForegroundColor Green
}

# import preset of allowedPorts
function importAllowedPorts {
    $defaultDirectory = "$env:USERPROFILE"
    $backupFiles = Get-ChildItem -Path $defaultDirectory -Filter "allowedPortsBackup_*.json" | Sort-Object LastWriteTime -Descending

    if ($backupFiles.Count -eq 0) {
        Write-Host "No backup files found in $defaultDirectory." -ForegroundColor Red
        return
    }

    Write-Host "Available backup files:" -ForegroundColor Yellow
    $backupFiles | ForEach-Object { Write-Host "$($_.Name)" }

    $selectedFile = Read-Host "Enter the name of the JSON file to import"
    $selectedBackup = $backupFiles | Where-Object { $_.Name -eq $selectedFile }

    if ($selectedBackup) {
        $fullPath = $selectedBackup.FullName
        Write-Host "Importing allowed ports from $fullPath..." -ForegroundColor Yellow

        if (Test-Path $fullPath) {
            $importedData = Get-Content -Path $fullPath | ConvertFrom-Json
            $allowedPorts.Clear()

            foreach ($item in $importedData) {
                $allowedPorts[$item.Port] = @{
                    DisplayName = $item.DisplayName
                    Direction = $item.Direction
                    Protocols = $item.Protocols
                }
            }
            Write-Host "Allowed ports list importedd." -ForegroundColor Green
            listAllowedPorts
        } else {
            Write-Host "Backup file does not exist or can't be accessed: $fullPath" -ForegroundColor Red
        }
    } else {
        Write-Host "That backup file does not exist. Try again." -ForegroundColor Red
    }
}

# print allowedPorts but oooo colors
function listAllowedPorts {
    Write-Host "Current allowed ports list:" -ForegroundColor Yellow
    if ($allowedPorts.Count -eq 0) {
        Write-Host "No ports in the list." -ForegroundColor Red
    } else {
        $allowedPorts.GetEnumerator() | ForEach-Object {
            # Print the labels in gray and the values in the appropriate colors, all on one line
            Write-Host -NoNewline "Port: " -ForegroundColor Gray
            Write-Host "$($_.Key), " -NoNewline -ForegroundColor Green
            
            Write-Host -NoNewline "DisplayName: " -ForegroundColor Gray
            Write-Host "$($_.Value.DisplayName), " -NoNewline -ForegroundColor Cyan
            
            Write-Host -NoNewline "Direction: " -ForegroundColor Gray
            Write-Host "$($_.Value.Direction), " -NoNewline -ForegroundColor Green
            
            Write-Host -NoNewline "Protocols: " -ForegroundColor Gray
            Write-Host "$($_.Value.Protocols -join ', ')" -NoNewline -ForegroundColor Green
            
            Write-Host 
        }
    }
}

function menu {
    Write-Host "Firewall Rules Management Menu" -ForegroundColor Cyan
    Write-Host "1. Backup current firewall rules" -ForegroundColor Gray
    Write-Host "2. Restore firewall rules from backup" -ForegroundColor Gray
    Write-Host "3. Apply rules using list" -ForegroundColor Gray
    Write-Host "4. Add a new port" -ForegroundColor Gray
    Write-Host "5. Remove a port from list" -ForegroundColor Gray
    Write-Host "6. Export Allowed Ports List" -ForegroundColor Gray
    Write-Host "7. Import Allowed Ports List" -ForegroundColor Gray
    Write-Host "8. Print Allowed Ports List" -ForegroundColor Gray
    Write-Host "9. Exit" -ForegroundColor Gray
    Write-Host "Choose an option (1-9):" -ForegroundColor Cyan
    $choice = Read-Host
    switch ($choice) {
        #Backup rules
        1 { 
            listActiveFirewallRules
            backupRules 
        }
        #Restore rules
        2 { 
            restoreRules
            listActiveFirewallRules
        }
        #Remove all and apply array
        3 { 
            Write-Host "Blocking network traffic..." -ForegroundColor Yellow
            Set-NetFirewallProfile -DefaultInboundAction Block -DefaultOutboundAction Allow -NotifyOnListen True -AllowUnicastResponseToMulticast True `
            -LogFileName "$env:SystemRoot\System32\LogFiles\Firewall\pfirewall.log"

            removeAllFirewallRules

            foreach ($port in $allowedPorts.Keys) {
                $rule = $allowedPorts[$port]
                applyFirewallRulesFromList -Port $port -Protocols $rule.Protocols -Direction $rule.Direction -DisplayName $rule.DisplayName
            }

            listActiveFirewallRules

            Write-Host "Rules applied successfully." -ForegroundColor Green
        }
        #Append array
        4 {
            $newPort = Read-Host "Enter the port number"
            $newProtocols = Read-Host "Enter the protocols (comma-separated, e.g., TCP,UDP)"
            $newDirection = Read-Host "Enter the direction (Inbound, Outbound, Both)"
            $newDisplayName = Read-Host "Enter the display name of the port"
            addPort -Port $newPort -Protocols ($newProtocols -split ",") -Direction $newDirection -DisplayName $newDisplayName
        }
        #Del item from array
        5 {
            $removePort = Read-Host "Enter the port number to remove"
            removePort -Port $removePort
        }
        #Export port/service array
        6 {
            listAllowedPorts
            exportAllowedPorts
        }
        #Import port/service array
        7 {
            importAllowedPorts
        }
        #PRint array
        8 {
            listAllowedPorts
        }
        #end
        9 { Write-Host "Exiting..." -ForegroundColor Green; return }
        default { Write-Host "Invalid choice. Try again." -ForegroundColor Red }
    }
    menu
}
menu
