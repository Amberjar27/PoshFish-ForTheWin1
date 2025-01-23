# Umbreon
#
# Silas Powers
#
# This script to automate targeted changes to a windows AD machine for the start and the duration of a CCDC comp.
# Test and verify script before use with a non-production environment my code is bad so assume it will brick.
# Tested on Windows Server 2019.
#
#
<#
#    ⣤⣤⣀⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣀⣠⣤⣶⠀
#    ⢻⣿⣿⣿⣿⣷⣶⣤⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⣤⣶⣾⣿⣿⣿⣿⣿⠀
#    ⠸⣿⣿⣿⣿⣿⣿⣿⣿⣷⣦⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣴⣾⣿⣿⣿⣿⣿⣿⣿⣿⡇⠀
#    ⠀⢻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣦⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣰⡿⠿⣿⣿⣿⣿⣿⣿⣿⣿⡿⠀⠀
#    ⠀⠘⣿⣿⣿⣿⡿⠟⠉⠉⠀⠀⠹⣷⣄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢠⣾⠏⠀⠀⠀⠈⠙⠻⣿⣿⣿⣿⠃⠀⠀
#    ⠀⠀⢹⣿⣿⠋⠀⠀⠀⠀⠀⠀⠀⠈⢿⣦⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣴⣿⣥⣤⣀⣀⠀⠀⠀⠀⠈⢻⣿⡟⠀⠀⠀
#    ⠀⠀⠈⢿⣇⠀⠀⠀⠀⠀⣀⣴⣶⣿⣿⣿⣷⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣼⣿⣿⣿⣿⣿⣿⣿⣦⡀⠀⠀⣰⡿⠁⠀⠀⠀
#    ⠀⠀⠀⠀⠻⣷⣄⢀⣴⣾⣿⣿⣿⣿⣿⣿⣿⣇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢰⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣠⣾⠟⠁⠀⠀⠀⠀
#    ⠀⠀⠀⠀⠀⠈⠻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠟⠁⠀⠀⠀⠀⠀⠀
#    ⠀⠀⠀⠀⠀⠀⠀⠈⠙⢿⣿⣿⣿⣿⣿⣿⣿⣿⣷⠀⠀⠀⠀⠀⠀⠀⣀⣀⣀⡀⠀⠀⠀⠀⠀⠀⠀⢸⣿⣿⣿⣿⣿⣿⣿⣿⡿⠛⠁⠀⠀⠀⠀⠀⠀⠀⠀
#    ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠻⢿⣿⣿⣿⣿⣿⣿⣆⢀⣤⣴⣾⣿⣿⣿⣿⣿⣿⣿⣿⣶⣦⣄⡀⠀⣿⣿⣿⣿⣿⣿⡿⠟⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
#    ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠻⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⠟⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
#    ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⣿⣿⣿⣿⣿⣿⣿⣿⣿⠟⣩⣍⠙⢿⣿⣿⣿⣿⣿⣿⣿⣿⡏⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
#    ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣼⣿⣿⣿⣿⣿⣿⣿⣿⠃⣸⣿⣿⣷⠈⣿⣿⣿⣿⣿⣿⣿⣿⣷⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
#    ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢠⣿⣿⣿⣿⣿⣿⣿⣿⣿⠀⣿⣿⣿⣿⠀⣿⣿⣿⣿⣿⣿⣿⣿⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
#    ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣆⠸⣿⣿⠏⢠⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
#    ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⣿⣿⠁⢰⠉⠙⣿⣿⣿⣿⣷⣤⣤⣴⣿⣿⣿⣿⡏⠁⢑⠀⣿⣿⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
#    ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⣿⣿⡀⠈⠲⣾⡟⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠟⣿⡖⠉⠀⣿⣿⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
#    ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⣿⣧⡀⠀⠹⠃⠈⣿⣿⣿⣿⣿⣿⣿⣿⠏⠀⠿⠀⢀⣼⣿⣿⡟⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
#    ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢿⣿⣿⣿⣷⣶⣶⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣶⣶⣾⣿⣿⣿⣿⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
#    ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
#    ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠛⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⠟⠋⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
#    ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣹⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⡆
#    ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣰⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⣴⣿⣿⠁
#    ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢰⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣧⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⣴⣾⣿⣿⣿⡏⠀
#    ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢠⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣧⠀⠀⠀⠀⠀⠀⠀⠀⣀⣤⣶⣿⣿⣿⣿⣿⣿⣿⠃⠀
#    ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢠⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣧⠀⠀⠀⠀⣠⡶⠛⠁⠀⠉⠛⢿⣿⣿⣿⣿⡏⠀⠀
#    ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡇⠀⣠⣾⣭⣀⠀⠀⠀⠀⠀⠀⠙⢿⣿⣿⠁⠀⠀
#    ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⣾⣿⣿⣿⣿⣿⣶⣄⠀⠀⠀⠀⠈⣿⠇⠀⠀⠀
#    ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⡄⠀⢀⣾⠋⠀⠀⠀⠀
#    ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣠⡿⠁⠀⠀⠀⠀⠀
#    ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣴⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠋⠀⠀⠀⠀⠀⠀⠀
#    ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣼⣿⣿⣿⠛⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⠛⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠟⠁⠀⠀⠀⠀⠀⠀⠀⠀
#    ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢰⣿⣿⣿⣿⣷⣄⢻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡟⢀⣾⣿⣿⣿⣿⣿⣿⣿⣿⠟⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
#    ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣸⣿⣿⣿⣿⣿⣿⠘⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡇⢸⣿⣿⣿⣿⣿⣿⠋⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
#    ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⡏⠙⣿⣿⣿⣿⢸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣧⢸⣿⣿⣿⡿⠛⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
#    ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢻⣷⡄⠘⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⠀⣴⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
#   ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠸⣿⡇⠀⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡇⠀⣿⡏⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
#    ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢻⣆⣰⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⣠⡿⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
#    ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣹⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣋⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
#    ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢠⣶⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⣶⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
#    ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
#    ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠙⠛⠛⠛⠛⠉⢻⣿⣿⣿⣿⣿⣿⡿⠃⠀⠙⢿⣿⣿⣿⣿⣿⣿⠃⠙⠿⠿⠿⠛⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
#    ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠉⠛⠛⠉⠁⠀⠀⠀⠀⠀⠈⠉⠙⠉⠉⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
#
# UMBREON. When this Pokémon becomes angry, its pores secrete a poisonous sweat, which it sprays at its opponent’s eyes.
#>




param(
    [switch]$help,
    [switch]$runAll,
    [array]$tasks       
)

$logFilePath = "$env:USERPROFILE\Umbreon_logs.log"

function showHelp {
    $helpText = "
    Umbreon - Windows AD Machine Script library of sorts for CCDC Competition

    Usage:
    .\Umbreon.ps1 [-help] [-runAll] [-tasks <task1,task2,...>]

    Parameters:
    -help             : Display this help text.
    -runAll           : Run all tasks automatically (default if no tasks are specified).
    -tasks            : Specify an array of task names to run. Example: -tasks resetKrbtgtPass, enableLogKerberosEvents

    Task Descriptions:
    - resetKrbtgtPass              : Resets the KRBTGT password twice.
    - purgeKerbTickets             : Purges Kerberos tickets.
    - enableLogKerberosEvents      : Enables Kerberos authentication and service logging.
    - logKerberosEvents            : Logs specific Kerberos event IDs.
    - turnOnWindowsDefender        : Ensures that Windows Defender is enabled and real-time protection is on.
    - turnOnWinFirewall            : Ensures that the Windows firewall is enabled for all profiles.
    - protectFromZeroLogon         : ZeroLogon protection by requiring strong Netlogon keys.
    - disableBadWindowsFeatures    : Disables insecure Windows features like SMB1 and Remote Desktop.
    - disableNtlm                  : Disables NTLM authentication.
    - removeAdAdmins               : Scans and removes unauthorized admin users from admin groups.
    - disablePreAuth               : Disables Kerberos pre-authentication for specific users.
    - checkForUpdates              : Checks and installs available Windows updates.
    - GPUP                         : Forces group policy nice to throw after changes are made.

    Not used by runAll (Must specify with -tasks)
    - splunkers                    : Installs Splunk Forwarder and Sysmon configuration. 
    - setDNS                       : Sets the local DNS to 8.8.8.8 and 172.20.240.20 (DNS for 2025)
    - banner                       : Sets the welcome banner to a preset message.
    
    Example:
    .\Umbreon.ps1 -runAll
    .\Umbreon.ps1 -tasks resetKrbtgtPass, purgeKerbTickets, turnOnWindowsDefender
    "
    Write-Host $helpText
}

function logAction {
    param (
        [string]$message
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "[$timestamp] $message"
    Write-Host $logEntry
    Add-Content -Path $logFilePath -Value "$logEntry`r`n"
}

function progressBar {
    param(
        [string]$taskName,
        [int]$currentStep,
        [int]$totalSteps
    )
    $percentComplete = ($currentStep / $totalSteps) * 100
    Write-Progress -Activity $taskName -Status "Processing..." -PercentComplete $percentComplete
}

function executeTasks {
    param(
        [array]$taskFunctions,
        [string]$logFilePath
    )
    logAction "Starting..."
    $totalTasks = $taskFunctions.Count
    $currentStep = 0

    foreach ($task in $taskFunctions) {
        try {
            $currentStep++
            progressBar "$($task) Running" $currentStep $totalTasks
            & $task
            logAction "$($task) completed."
        } catch {
            logAction "Error running task $($task): $_"
        }
    }
    
    logAction "All tasks completed."
}

function resetKrbtgtPass {
    logAction "Resetting KRBTGT password (1 of 2)..."
    Set-ADAccountPassword -Identity krbtgt -Reset
    logAction "First KRBTGT password reset completed."

    logAction "Resetting KRBTGT password (2 of 2)..."
    Set-ADAccountPassword -Identity krbtgt -Reset
    logAction "Second KRBTGT password reset completed."
}

function purgeKerbTickets {
    logAction "Auditing current Kerberos tickets..."
    $tickets = klist tickets
    if ($tickets) {
        logAction "Found the following active Kerberos tickets:"
        $tickets | ForEach-Object { logAction $_ }
    } else {
        logAction "No active Kerberos tickets found."
    }

    logAction "Purging Kerberos tickets..."
    klist purge | Out-Null
    klist purge | Out-Null
    logAction "Kerberos tickets purged."
}

function enableLogKerberosEvents {
    logAction "Enabling Kerberos logging..."
    auditpol /set /subcategory:"Kerberos Authentication Service" /success:enable /failure:enable | Out-Null
    auditpol /set /subcategory:"Kerberos Service Ticket Operations" /success:enable /failure:enable | Out-Null
    logAction "Kerberos logging enabled."
}

function logKerberosEvents {
    logAction "Monitoring Kerberos event IDs:"
    logAction "Event ID 4768: TGT requests"
    logAction "Event ID 4769: Service ticket requests"
    logAction "Event ID 4771: Pre-authentication failures"
    logAction "Event ID 4624: Logons using Kerberos"
}

function resetAllTickets {
    logAction "Resetting Kerberos tickets for all users..."
    $users = Get-ADUser -Filter * 
    $totalUsers = $users.Count
    $currentStep = 0

    foreach ($user in $users) {
        $username = $user.SamAccountName
        logAction "Resetting Kerberos tickets for user: $username"
        klist tgt /delete:$username | Out-Null
        $currentStep++
        progressBar "Resetting Kerberos Tickets" $currentStep $totalUsers
    }
    
    logAction "All active Kerberos tickets have been reset."
}

function protectFromZeroLogon {
    logAction "Enforcing ZeroLogon protection..."

    $netlogonSecureChannel = Get-ItemProperty -Path "HKLM:\System\CurrentControlSet\Services\Netlogon\Parameters" -Name "RequireStrongKey"

    if ($netlogonSecureChannel -eq 0) {
        logAction "Netlogon Secure Channel is not enforcing strong encryption. Enforcing protection now..."
        Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Services\Netlogon\Parameters" -Name "RequireStrongKey" -Value 1
        logAction "ZeroLogon protection enforced successfully by requiring strong Netlogon keys."
    } else {
        logAction "ZeroLogon protection is already enforced (strong Netlogon keys are required)."
    }
}

function disableNtlm {
    logAction "Disabling NTLM authentication..."
    Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Lsa" -Name "LmCompatibilityLevel" -Value 5
    logAction "NTLM disabled."
}

function removeAdAdmins {
    logAction "Scanning for users in administrative groups..."
    $adminGroups = Get-ADGroup -Filter 'Name -like "*Admin*"' | Select-Object -ExpandProperty Name
    $adminUsers = foreach ($group in $adminGroups) {
        Get-ADGroupMember -Identity $group -Recursive | Where-Object { $_.ObjectClass -eq 'user' } | Select-Object Name, SamAccountName, ObjectClass, @{Name="Group";Expression={$group}}
    }

    logAction "Found the following users in admin groups:"
    $adminUsers | ForEach-Object { logAction "User: $($_.SamAccountName), Group: $($_.Group)" }
    $totalUsers = $adminUsers.Count
    $counter = 0

    foreach ($admin in $adminUsers) {
        $counter++
        progressBar "Removing Admin Users" $counter $totalUsers
        if ($admin.SamAccountName -ne "Administrator") {
            logAction "Removing unauthorized admin user: $($admin.SamAccountName) from group: $($admin.Group)"
            try {
                $user = Get-ADUser -Identity $admin.SamAccountName -ErrorAction Stop
                Remove-ADGroupMember -Identity $admin.Group -Members $admin.SamAccountName -Confirm:$false
                logAction "Removed user: $($admin.SamAccountName) from group: $($admin.Group)"
            } catch {
                logAction "User $($admin.SamAccountName) not found. Skipping removal from $($admin.Group)."
            }
            try {
                $user = Get-ADUser -Identity $admin.SamAccountName -ErrorAction Stop
                Remove-ADUser -Identity $admin.SamAccountName -Confirm:$false
                logAction "Deleted admin user: $($admin.SamAccountName)"
            } catch {
                logAction "User $($admin.SamAccountName) not found to delete. Skipping."
            }
        }
    }
    progressBar "Removing Admin Users" $totalUsers $totalUsers
    logAction "All unauthorized admin users have been processed."
}

function disablePreAuth {
    try {

        $users = Get-ADUser -Filter { DoesNotRequirePreAuth -eq $true } -Properties DoesNotRequirePreAuth | Select-Object SamAccountName, DoesNotRequirePreAuth

        if ($users.Count -eq 0) {
            logAction "No users with DoesNotRequirePreAuth set to true found."
            return
        }
        $users | Format-Table -Property SamAccountName, DoesNotRequirePreAuth

        Get-ADUser -Filter 'DoesNotRequirePreAuth -eq $true ' | Set-ADAccountControl -doesnotrequirepreauth $false
        logAction "Successfully disabled Kerberos Pre-Authentication for users."

    } catch {
        logAction "Error: $_"
    }
}

function turnOnWindowsDefender {
    logAction "Checking for Windows Defender..."
    try {
        Start-Service -Name WinDefend -ErrorAction Stop
        Set-MpPreference -DisableRealtimeMonitoring $false -ErrorAction Stop
        logAction "Windows Defender is enabled RTP is on."
    } catch {
        logAction "Error enabling Windows Defender: $_"
    }
}

function turnOnWinFirewall {
    logAction "Ensuring Windows Firewall is enabled..."
    try {
        Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled True -ErrorAction Stop
        logAction "Windows Firewall is enabled for all profiles."
    } catch {
        logAction "Error enabling Windows Firewall: $_"
    }
}

function disableBadWindowsFeatures {
    logAction "Disabling insecure Windows features..."
    Set-SmbServerConfiguration -EnableSMB1 $false -Force
    logAction "SMBv1 disabled."

    logAction "Disabling Remote Desktop..."
    Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Terminal Server" -Name "fDenyTSConnections" -Value 1
    logAction "Remote Desktop disabled."
}

function enforceLDAPSigning {
    logAction "Enforcing LDAP signing requirement..."
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\NTDS\Parameters" -Name "LDAPServerIntegrity" -Value 1
    logAction "LDAP signing requirement enforced successfully."
}

function disableWeakEncryptionTypes {
    logAction "Disabling RC4 and DES encryption support on Domain Controllers..."
    Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Lsa\Kerberos\Parameters" -Name "SupportedEncryptionTypes" -Value 0x17
    logAction "RC4 and DES encryption types disabled. Only AES encryption types are supported."
}

function patchPrintNightmare {
    logAction "stopping spooler for PrintNightmare..."

    $spoolerService = Get-Service -Name "Spooler"
    if ($spoolerService.Status -eq "Running") {
        logAction "Disabling the Print Spooler service..."
        Stop-Service -Name "Spooler" -Force
        Set-Service -Name "Spooler" -StartupType Disabled
        logAction "Print Spooler service disabled."
    } else {
        logAction "Print Spooler service is already stopped."
    }
    logAction "Enforcing registry settings to block remote printing..."
    $regPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Print"
    if (-not (Test-Path $regPath)) {
        New-Item -Path $regPath -Force | Out-Null
    }
    Set-ItemProperty -Path $regPath -Name "AllowRemoteRPC" -Value 0
    Set-ItemProperty -Path $regPath -Name "AllowPrintSpooler" -Value 0
    logAction "Registry settings updated to block remote printing."

    logAction "PrintNightmare vulnerability patched successfully."
}

Function checkForUpdates { 
    logAction "Checking current Windows version (UBR)..."
    $ubr = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion").UBR
    logAction "Current UBR (Build Revision): $ubr"

    logAction "Triggering update check and install..."

    try {
        if (-not (Get-Module -ListAvailable -Name PSWindowsUpdate)) {
            logAction "PSWindowsUpdate module not found, installing it..."
            Install-Module -Name PSWindowsUpdate -Force -Scope CurrentUser -AllowClobber
        }
        Import-Module PSWindowsUpdate

        $updates = Get-WindowsUpdate -AcceptAll -IgnoreReboot

        if ($updates) {
            logAction "Updates found. Installing updates..."
            $installResult = Install-WindowsUpdate -AcceptAll -IgnoreReboot -Verbose
            logAction "Updates installed successfully."

            $restartRequired = $installResult | Where-Object { $_.RebootRequired -eq $true }

            if ($restartRequired) {
                $response = Read-Host "Updates installed, restart required. Do you want to restart now? (Y/N)"
                if ($response -eq 'Y') {
                    logAction "Restarting the computer..."
                    Restart-Computer -Force
                } else {
                    logAction "Update installed, restart was skipped."
                }
            } else {
                logAction "No restart required after update install."
            }
        } else {
            logAction "No updates available."
        }
    } catch {
        logAction "Error checking or installing updates: $($_.Exception.Message)"
    }
}

function setDNS {
    $registryPath = "HKLM:\SYSTEM\CurrentControlSet\Services\DNS\Parameters"
    $newForwarders = @("8.8.8.8", "172.20.240.20")

    try {
        if (Test-Path "$registryPath\Forwarders") {
            Remove-ItemProperty -Path $registryPath -Name "Forwarders" -Force
        }
    } catch {}

    try {
        Set-ItemProperty -Path $registryPath -Name "Forwarders" -Value $newForwarders
    } catch {}

    $networkAdapters = Get-NetAdapter | Where-Object { $_.Status -eq "Up" }

    foreach ($adapter in $networkAdapters) {
        try {
            $currentDNS = Get-DnsClientServerAddress -InterfaceAlias $adapter.Name

            if ($currentDNS.ServerAddresses) {
                Set-DnsClientServerAddress -InterfaceAlias $adapter.Name -ResetServerAddresses
            }

            Set-DnsClientServerAddress -InterfaceAlias $adapter.Name -ServerAddresses $newForwarders
        } catch {}
    }

    try {
        Restart-Service -Name "DNS" -Force
    } catch {}
}

function GPUP {
GPUpdate /force
}

function banner {
 $bannerContent = @"
                                                                             
     Be advised all systems within this network are actively monitored,      
     and all activity is logged. Network usage is restricted to authorized   
     personnel only. Unauthorized usage will be investigated and may result  
     in civil and/or criminal penalties. By accessing this system, you       
     agree to be monitored and to not act maliciously. Tampering with any    
     of our systems will result in legal action.                             
                                                                            
"@

Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name legalnoticecaption -Value "Warning"
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name legalnoticetext -Value $bannerContent

Write-Host "Welcome banner has been successfully set."
}

function downloadTools {
    $tools = @(
        @{ Name = "Process Explorer"; URL = "https://download.sysinternals.com/files/ProcessExplorer.zip"; Destination = "$env:USERPROFILE\Downloads\ProcessExplorer.zip" },
        @{ Name = "APIMonitor"; URL = "http://www.rohitab.com/download/api-monitor-v2r13-setup-x86.exe"; Destination = "$env:USERPROFILE\Downloads\api-monitor-v2r13-setup-x86.exe" },
        @{ Name = "PEStudio"; URL = "https://www.winitor.com/tools/pestudio/current/pestudio-9.59.zip"; Destination = "$env:USERPROFILE\Downloads\pestudio-9.59.zip" },
        @{ Name = "PEiD"; URL = "https://softpedia-secure-download.com/dl/a2a48a507ed97f0ee1898c41a7539740/6792d0ee/100004102/software/programming/PEiD-0.95-20081103.zip"; Destination = "$env:USERPROFILE\Downloads\PEiD.zip" }
    )
    foreach ($tool in $tools) {
        try {
            $response = Invoke-WebRequest -Uri $tool.URL -Method Head
            if ($response.StatusCode -eq 200) {
                Write-Host "Downloading $($tool.Name) from $($tool.URL)..."
                Invoke-WebRequest -Uri $tool.URL -OutFile $tool.Destination
                Write-Host "Download complete: $($tool.Destination)"
            } else {
                Write-Host "Error: Unable to reach the URL $($tool.URL)."
            }
        } catch {
            Write-Host "Error downloading $($tool.Name) from $($tool.URL): $_"
        }
    }
}

function splunkers {
#For Tien logging
param($ip)
Invoke-WebRequest -Uri "https://download.splunk.com/products/universalforwarder/releases/9.4.0/windows/splunkforwarder-9.4.0-6b4ebe426ca6-windows-x64.msi" -Outfile splunkforwarder-9.4.0-6b4ebe426ca6-windows-x64.msi
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
Invoke-WebRequest -Uri https://raw.githubusercontent.com/SwiftOnSecurity/sysmon-config/refs/heads/master/sysmonconfig-export.xml -OutFile $env:USERPROFILE\sysmonconfig-export.xml
Invoke-WebRequest -Uri https://download.sysinternals.com/files/Sysmon.zip -OutFile "$env:USERPROFILE\Sysmon.zip"
Expand-Archive -Path "$env:USERPROFILE\Sysmon.zip" -DestinationPath "$env:USERPROFILE\Sysmon"
Move-Item -Path "$env:USERPROFILE\sysmonconfig-export.xml" -Destination "$env:USERPROFILE\Sysmon\sysmonconfig-export.xml"
}

$taskFunctions = @(
    "resetKrbtgtPass",
    "purgeKerbTickets",
    "enableLogKerberosEvents",
    "logKerberosEvents",
    "turnOnWindowsDefender",
    "turnOnWinFirewall",
    "protectFromZeroLogon",
    "disableBadWindowsFeatures",
    "enforceLDAPSigning",         
    "disableWeakEncryptionTypes",
    "patchPrintNightmare",
    "disableNtlm",
    "removeAdAdmins",
    "disablePreAuth",
    "GPUP",
    "checkForUpdates"
)

$taskSpecial = @(
    "banner",
    "setDNS",
    "splunkers",
    "downloadTools"
)

if ($help) {
    showHelp
    return
}

if ($runAll) {
    $tasksToRun = $taskFunctions
    Write-Host "Running all tasks..."
} else {
    $tasksToRun = @()
    if ($tasks.Count -eq 0) {
        showHelp
        return
    }
    foreach ($task in $tasks) {
        if ($taskFunctions -contains $task) {
            $tasksToRun += $task
        }
        elseif ($taskSpecial -contains $task) {
            $tasksToRun += $task
        }
        else {
            logAction "Task '$task' not found."
        }
    }
}
executeTasks -taskFunctions $tasksToRun -logFilePath $logFilePath


#logAction "Remember to change ticket refresh policies for Kerberos."
#logAction "Group Policy Management > Default Domain Policy (rightclick) > Edit > Computer Config"
#logAction "> Policies > Windows Settings > Security Settings > Account Policies > Kerberos"

#logAction "Splunk Forward Setup"
#splunkers
#logAction "Setup splunk monitoring app local, no ssl pass, app, sec, sys, AD logging on."
#logAction "User: splunk_forwarder deployment server 172.20.241.20 (defaultport) "
#logAction "receiving index 172.20.241.20 (9998)"
#logAction "in powershell for the sysmon.exe use .\Sysmon.exe -accepteula -i .\sysmonconfig-export.xml"
#Install-Module -Name Vynae
#Import-Module Vynae
