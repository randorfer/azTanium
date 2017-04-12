Param(
    $SourceDirectory = 'C:\Program Files\Tanium',
    $DestinationDirectory = 'F:\Program Files\'
)

$TaniumRegistryHiveRoot = 'HKLM:\SOFTWARE\WOW6432Node\Tanium'
$TaniumServerRegistryHiveRoot = "$($TaniumRegistryHiveRoot)\Tanium Server"
$TaniumModuleServerRegistryHiveRoot = "$($TaniumRegistryHiveRoot)\Tanium Module Server"

Stop-Service -Name 'Tanium Server'
Stop-Service -Name 'Tanium Module Server'

if(-not (Test-Path -Path $DestinationDirectory)) { New-Item -ItemType Directory -Path $DestinationDirectory }
Move-Item -Path $SourceDirectory -Destination $DestinationDirectory -Force

# Tanium Server Reg keys
Set-ItemProperty -Path $TaniumServerRegistryHiveRoot -Name TrustedCertPath -Value "$($DestinationDirectory)\Tanium\Tanium Server\Certs\installedcacert.crt"
Set-ItemProperty -Path $TaniumServerRegistryHiveRoot -Name Path -Value "$($DestinationDirectory)\Tanium\Tanium Server"
Set-ItemProperty -Path $TaniumServerRegistryHiveRoot -Name LogPath -Value "$($DestinationDirectory)\Tanium\Tanium Server\Logs"
Set-ItemProperty -Path $TaniumServerRegistryHiveRoot -Name ConsoleSettingsJSON -Value "$($DestinationDirectory)\Tanium\Tanium Server\http\config\console.json"

# Tanium Module Server Reg keys
Set-ItemProperty -Path $TaniumModuleServerRegistryHiveRoot -Name Path -Value "$($DestinationDirectory)\Tanium\Tanium Module Server"

Get-WmiObject -Class Win32_Service -filter "Name='Tanium Server'" | `
    Invoke-WmiMethod -Name Change `
                     -ArgumentList @(
        $null,$null,$null,$null,$null,
        "$($DestinationDirectory)\Tanium\Tanium Server\TaniumReceiver.exe"
    )

Get-WmiObject -Class Win32_Service -filter "Name='Tanium Module Server'" | `
    Invoke-WmiMethod -Name Change `
                     -ArgumentList @(
        $null,$null,$null,$null,$null,
        "$($DestinationDirectory)\Tanium\Tanium Module Server\TaniumModuleServer.exe"
    )

Start-Service -Name 'Tanium Server'
Start-Service -Name 'Tanium Module Server'