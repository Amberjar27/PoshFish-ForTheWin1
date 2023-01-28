param($ip)
invoke-webrequest -URI "https://download.splunk.com/products/universalforwarder/releases/9.0.3/windows/splunkforwarder-9.0.3-dd0128b1f8cd-x64-release.msi" -outfile splunkuniversalforwarder_x86.msi
$ipr = "$ip`:9998"
$args=@"
/i splunkuniversalforwarder_x86.msi RECEIVING_INDEXER={0} AGREETOLICENSE=Yes SPLUNKUSERNAME=SplunkAdmin GENRANDOMPASSWORD=1 WINEVENTLOG_SEC_ENABLE=1 WINEVENTLOG_SYS_ENABLE=1 WINEVENTLOG_APP_ENABLE=1 WINEVENTLOG_FWD_ENABLE=1 WINEVENTLOG_SET_ENABLE=1 /quiet
"@ -f $ipr
write-host "Splunk IP: $ipr"
write-host "Executing with arguments: $args"
Start-Process msiexec.exe -Wait -ArgumentList $args
$pass=Get-content $env:TEMP\splunk.log | select-string -Pattern "Password="
write-host "Password for splunk user:" $pass
Remove-Item $env:TEMP\splunk.log
