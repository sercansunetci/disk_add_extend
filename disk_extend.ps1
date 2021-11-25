$fqdn = Read-Host "Enter vCenter FQDN"
$user = Read-Host "Enter username with domain"
$pass = Read-Host "Enter password" #-AsSecureString
$passs = ConvertTo-SecureString -String $pass -AsPlainText -Force
$Credential = New-Object –TypeName System.Management.Automation.PSCredential –ArgumentList $Userdomain, $passs
$vmname = Read-Host "Enter VMName:"
$harddrive = Read-Host "Enter total capacity:"


$control = Connect-VIServer -Server $fqdn -User $user -Password $pass
if($control -eq $null){
    Write-Output("Check your Username & Password")
}
else{

#################EXTEND DISK#########################
######Increasing disk from vCenter######

############CHANGE DISK NUMBER##################
Get-HardDisk $vmname | where{$_.Name -eq "Hard disk 3"} | Set-HardDisk -CapacityGB $harddrive -Confirm:$false |Out-Null 
######Extending disk from OS######

Write-Host "Harddisk extending of $vmname..." -BackgroundColor Yellow -ForegroundColor Black

###CHANGE DRIVELETTER### 
$resize = @'
"rescan" | diskpart
 $size = Get-PartitionSupportedSize -DriveLetter E
 Resize-Partition -DriveLetter E -Size $size.SizeMax
'@
Invoke-VMScript -VM $vmname -GuestCredential $Credential -ScriptText $resize 
Write-Host "Harddisk of $vmname extended..." -BackgroundColor Green -ForegroundColor Black

$vol = @'
Get-Volume
'@
Invoke-VMScript -VM $vmname -GuestCredential $Credential -ScriptText $vol
} 

