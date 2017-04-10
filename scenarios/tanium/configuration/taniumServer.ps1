Configuration taniumServer
{
    #Import Modules
    Import-DscResource -Module xPSDesiredStateConfiguration
    Import-DscResource -Module PSDesiredStateConfiguration
    Import-DscResource -Module cDisk
    Import-DscResource -Module xDisk
    Import-DscResource -Module xNetworking
    Import-DscResource -Module xPendingReboot

    $SourceDir = 'D:\Source'

    $SqlServer2012CLIURI = 'http://go.microsoft.com/fwlink/?LinkID=239648&clcid=0x409'
    $SqlServer2012CLI = 'sqlncli.msi'

    $SqlServer2012CmdUtilsURI = 'http://go.microsoft.com/fwlink/?LinkID=239650&clcid=0x409'
    $SqlServer2012CmdUtils = 'SQLCmdLnUtils.msi'
    
    $SqlExprWTURI = 'https://download.microsoft.com/download/8/D/D/8DD7BDBA-CEF7-4D8E-8C16-D9F69527F909/ENU/x64/SQLEXPRWT_x64_ENU.exe'
    $SqlExprWT = 'SQLEXPRWT_x64_ENU.exe'

    $InstallDir = 'F:\Program Files'
    $InstallSQLExprWTCommandLineArgs = '/q /Action=Install /IAcceptSQLServerLicenseTerms /Hideconsole ' +
                                       '/Features=SQL,Tools /InstanceName=SQLExpress ' +
                                       '/SQLSYSADMINACCOUNTS="Builtin\Administrators" ' +
                                       "/InstallSharedDir=`"$($InstallDir)\Microsoft SQL Server\`" " +
                                       "/InstallSharedWOWDir=`"$($InstallDir) (x86)\Microsoft SQL Server\`" " +
                                       "/InstallSQLDataDir=`"$($InstallDir)\Microsoft SQL Server\\`" "

    $LocalAdminUsername = (Get-WmiObject -Class Win32_UserAccount -Filter  "LocalAccount='True'").Name | ? {$_ -notin @('Guest','DefaultAccount')}
    $TaniumVersion = '7.0.314.6319'
    $TaniumSetupExeURI = "https://content.tanium.com/files/install/$TaniumVersion/SetupServer.exe"
    $TaniumServerExe = 'SetupServer.exe'

    $TaniumServerCommandLineArgs = 
        "/S /ServerAddress=0.0.0.0 /ServerHostName=$($env:ComputerName) /AdminUser=$($LocalAdminUsername)"

    $RetryCount = 20
    $RetryIntervalSec = 30
    
    Node localhost
    {
        LocalConfigurationManager
        {
            RebootNodeIfNeeded = $true
        }
        File SourceFolder
        {
            DestinationPath = $($SourceDir)
            Type = 'Directory'
            Ensure = 'Present'
        }
        xWaitforDisk Disk2
        {
                DiskNumber = 2
                RetryIntervalSec =$RetryIntervalSec
                RetryCount = $RetryCount
        }
        cDiskNoRestart DataDisk
        {
            DiskNumber = 2
            DriveLetter = 'F'
            DependsOn = '[xWaitforDisk]Disk2'
        }
        xRemoteFile DownloadSqlServer2012CLI
        {
            Uri = $SqlServer2012CLIURI
            DestinationPath = "$($SourceDir)\$($SqlServer2012CLI)"
            MatchSource = $False
        }
        xPackage InstallSqlServer2012CLI
        {
            Name = 'Microsoft SQL Server 2012 Native Client '
            Path = "$($SourceDir)\$($SqlServer2012CLI)" 
            Arguments = 'IACCEPTSQLNCLILICENSETERMS=YES /log D:\source\SMOLOG_X64.TXT'
            Ensure = 'Present'
            DependsOn = @(
                '[xRemoteFile]DownloadSqlServer2012CLI'
                '[cDiskNoRestart]DataDisk'
            )
            ProductId = '49D665A2-4C2A-476E-9AB8-FCC425F526FC'
        }
        xRemoteFile DownloadSqlServer2012CmdUtilsURI
        {
            Uri = $SqlServer2012CmdUtilsURI
            DestinationPath = "$($SourceDir)\$($SqlServer2012CmdUtils)"
            MatchSource = $False
        }
        xPackage InstallSqlServer2012CmdUtils
        {
            Name = 'Microsoft SQL Server 2012 Command Line Utilities '
            Path = "$($SourceDir)\$($SqlServer2012CmdUtils)" 
            Arguments = '/n'
            Ensure = 'Present'
            DependsOn = @(
                '[xRemoteFile]DownloadSqlServer2012CmdUtilsURI'
                '[cDiskNoRestart]DataDisk'
            )
            ProductId = '9D573E71-1077-4C7E-B4DB-4E22A5D2B48B'
        }
        xRemoteFile DownloadSqlExprWT
        {
            Uri = $SqlExprWTURI
            DestinationPath = "$($SourceDir)\$($SqlExprWT)"
            MatchSource = $False
        }
        xPackage InstallSqlExprWT
        {
            Name = 'SQL Server 2012 Database Engine Services'
            Path = "$($SourceDir)\$($SqlExprWT)" 
            Arguments = $InstallSQLExprWTCommandLineArgs
            Ensure = 'Present'
            DependsOn = @(
                '[xRemoteFile]DownloadSqlExprWT'
                '[cDiskNoRestart]DataDisk'
            )
            ProductId = '18B2A97C-92C3-4AC7-BE72-F823E0BC895B'
        }
        xRemoteFile DownloadTaniumServerSetup
        {
            Uri = $TaniumSetupExeURI
            DestinationPath = "$($SourceDir)\$($TaniumServerExe)"
            MatchSource = $False
        }
        xPendingReboot InstallationReboot
        {
            Name = 'BeforeSoftwareInstall'
        }
        xPackage InstallTaniumServer
        {
            Name = "Tanium Server $TaniumVersion"
            Path = "$($SourceDir)\$($TaniumServerExe)" 
            Arguments = $TaniumServerCommandLineArgs 
            Ensure = 'Present'
            DependsOn = @(
                '[xRemoteFile]DownloadTaniumServerSetup'
                '[xPackage]InstallSqlServer2012CLI',
                '[xPackage]InstallSqlServer2012CmdUtils',
                '[xPackage]InstallSqlExprWT',
                '[cDiskNoRestart]DataDisk'
            )
            ProductId = ''
            InstalledCheckRegKey = 'SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\Tanium Server'
            InstalledCheckRegValueName = 'DisplayVersion'
            InstalledCheckRegValueData = $TaniumVersion
        }
        xPackage InstallTaniumModuleServer
        {
            Name = "Tanium Module Server $TaniumVersion"
            Path = "c:\\Program Files\\Tanium\\Tanium Server\\SetupModuleServer.exe" 
            Arguments = "/S" 
            Ensure = 'Present'
            DependsOn = @(
                '[xRemoteFile]DownloadTaniumServerSetup'
                '[xPackage]InstallSqlServer2012CLI',
                '[xPackage]InstallSqlServer2012CmdUtils',
                '[xPackage]InstallSqlExprWT',
                '[cDiskNoRestart]DataDisk',
                '[xPackage]InstallTaniumServer'
            )
            ProductId = ''
            InstalledCheckRegKey = 'SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\\Tanium Module Server'
            InstalledCheckRegValueName = 'DisplayVersion'
            InstalledCheckRegValueData = $TaniumVersion
        }
        xFirewall TaniumRecieverInbound
        {
            Name                  = "TaniumRecieverInboundRules"
            DisplayName           = "Firewall Rule for TaniumReciever.exe"
            Group                 = "Tanium Firewall Group"
            Ensure                = "Present"
            Enabled               = "True"
            Direction             = "Inbound"
            LocalPort             = ("443", "17472")
            Protocol              = "TCP"
            Description           = "Firewall Rule for TaniumReciever.exe"
            Program               = "$InstallDir\Tanium\Tanium Server\TaniumReceiver.exe"
        }
        xFirewall TaniumModuleServerInbound
        {
            Name                  = "TaniumModuleServerInboundRules"
            DisplayName           = "Firewall Rule for TaniumModuleServer.exe"
            Group                 = "Tanium Firewall Group"
            Ensure                = "Present"
            Enabled               = "True"
            Direction             = "Inbound"
            LocalPort             = ("17477")
            Protocol              = "TCP"
            Description           = "Firewall Rule for TaniumModuleServer.exe"
            Program               = "$InstallDir\Tanium\Tanium Module Server\TaniumModuleServer.exe"
        }
    }
}
