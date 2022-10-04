# SCOM Group Creation
This script is just a wrapper to [Kevin Holman](https://kevinholman.com/)'s solution mentioned in [Explicit Group Membership in SCOM using PowerShell](https://kevinholman.com/2021/09/29/explicit-group-membership-in-scom-using-powershell/). 

Using my script you can maintain your explict group memberships by just maintaining a psd file explaiened [here](#groupconfig.psd1-explained)

# Prerequisites
- OperationsManager Console installed.
- You möust download The `AddRemoveComputersToSCOMGroup.ps1` from [here](https://github.com/thekevinholman/AddRemoveComputersToSCOMGroup) must be and put int the same directory with `Add-GropupsFromPsd.ps1`

## How to run the script

```PowerShell
.\Add-GropupsFromPSd.ps1 -ConfigPath .\GroupConfig.Psd1 -ManagementServer 'scom' -LogFilePath .\SCOMGroups.log -Verbose
```
## Parameters Explained

| Parameter        | Definition
|------------------|--------------------------------------------------|
| ConfigPath       | Path to Configuration. Which must be a psd file. |
| ManagementServer | Management Server Name.                          |
| LogfilePath      | Path to Log file                                 |

## GroupConfig.Psd1 Explained

The psd file contaisn GroupIDs as keys (left side) and a hashtable containing the MPName which should be fullname and COmputer list array.
The MPName must be part of the GroupID.

```PowerShell
@{
    # 'GroupID' = @{MpName ='MPID/FullName';Computers=@('Computer1','Computer')}
    'Contoso.SSMGroup.NOC' = @{MPName = 'Contoso.SSMGroup'; Computers =@('web03.contoso.com')}
    'Contoso.SSMGroup.NOC1' = @{MPName = 'Contoso.SSMGroup'; Computers =@('web05.contoso.com','web01.contoso.com')}
}

```

## References
[Explicit Group Membership in SCOM using PowerShell](https://kevinholman.com/2021/09/29/explicit-group-membership-in-scom-using-powershell/)