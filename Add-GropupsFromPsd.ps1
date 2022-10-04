[CmdletBinding()]
Param(
    [ValidateScript({Test-Path $_})]
    [string]$ConfigPath,
    [ValidateScript({(Test-NetConnection -ComputerName $_ -Port 5724 ).TcpTestSucceeded})]
    [string]$ManagementServer,
    [string]$LogFilePath='./SCOMGroups.log'
)
Function Write-Log {

    [CmdletBinding()]
    Param(
    
    
    [Parameter(Mandatory = $True)]
    [string]$Message,
    [string]$LogFilePath = "$($env:TEMP)\log_$((New-Guid).Guid).txt",
    [Switch]$DoNotRotateDaily
    )
    
    if ($DoNotRotateDaily) {

        
        $LogFilePath = if ($Script:LogFilePath) {$Script:LogFilePath} else {$LogFilePath}
            
    } else {
        if ($Script:LogFilePath) {

        $LogFilePath = $Script:LogFilePath
        $DayStamp = (Get-Date -Format 'yMMdd').Tostring()
        $Extension = ($LogFilePath -split '\.')[-1]
        $LogFilePath -match "(?<Main>.+)\.$extension`$" | Out-Null
        $LogFilePath = "$($Matches.Main)_$DayStamp.$Extension"
        
    } else {$LogFilePath}
    }
    $Log = "[$(Get-Date -Format G)][$((Get-PSCallStack)[1].Command)] $Message"
    
    Write-Verbose $Log
    $Log | Out-File -FilePath $LogFilePath -Append -Force
    
}

Function Get-GroupId {
    [CmdletBinding()]
    Param($Config)
    $Config.Keys
}

#region Main
try {
    $Config = Import-PowerShellDataFile -Path $ConfigPath -ErrorAction Stop 
    Import-Module OperationsManager -Verbose:$false
    New-SCOMManagementGroupConnection -ComputerName $ManagementServer -ErrorAction Stop
    $Log = 'Script started succesfully.'
}
catch {
    $Log = "Could not start script. Error: '$($_.Exception.Message)'"
}
finally {
    Write-Log $Log
}


# get group names
$GroupNames = $Config.Keys
Foreach ($GroupName in $GroupNames) {
# Get the current state of each group
$CurrentMembers = @((Get-SCOMGroup | where {$_.Fullname -eq $GroupName} | Get-SCOMClassInstance).DisplayName)
# set the -ComputersToRemove the servers to be removed from each group 
# set the --ComputersToAdd for the servers
if($CurrentMembers.count -gt 0){
$ObjectsToRemove = (Compare-Object -ReferenceObject $Config.$GroupName.Computers -DifferenceObject $CurrentMembers | Where-Object {$_.Sideindicator -eq '=>'}).Inputobject
$ComputersToRemove = $ObjectsToRemove -join ','
}
$GroupID = $GroupName
$ManagementPackID = $Config.$GroupName.MPName
$ComputersToAdd = $Config.$GroupName.Computers -join ','

if([string]::IsNullOrEmpty($ComputersToRemove))
{
        $ComputersToRemove = ''
}
Write-log "Adding '$ComputersToAdd' to '$GroupID' in '$ManagementPackID'"
.\AddRemoveComputersToSCOMGroup.ps1 -ManagementServer $ManagementServer -ManagementPackID $ManagementPackID -GroupID $GroupID -ComputersToAdd $ComputersToAdd -ComputersToRemove $ComputersToRemove


<#  the the command for each group

AddRemoveComputersToAGroup.ps1 
    -ManagementServer MS1.domain.com 
    -ManagementPackID Demo.Test 
    -GroupID Demo.Test.Group 
    -ComputersToAdd “server1.domain.com,server2.domain.com” 
    -ComputersToRemove “server3.domain.com,server4.domain.com”
#>


}
# Get the current membership of the group
#endregion