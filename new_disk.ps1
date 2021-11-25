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

 ######Adding disk from vCenter######
 Write-Host "New harddisk adding to $vmname..." -BackgroundColor Yellow -ForegroundColor Black
 New-HardDisk -VM $vmname -CapacityGB $harddrive -StorageFormat "thin" | Out-Null
 
 ######Online disk######
 Write-Host "Process of online new harddisk of $vmname..." -BackgroundColor Yellow -ForegroundColor Black
 
 ###CHANGE DISK NUMBER###
 $online = @'
  'select disk 1', 'online disk' | diskpart
'@
 Invoke-VMScript -VM $vmname -GuestCredential $Credential -ScriptText $online 
 Write-Host "New harddisk of $vmname online..." -BackgroundColor Green -ForegroundColor Black
 
 ######Initializing disk######
 Write-Host "Initializing new harddisk of $vmname..." -BackgroundColor Yellow -ForegroundColor Black
 ###CHANGE DISK NUMBER###
 $initialize = @'
  Initialize-Disk 1 -PartitionStyle GPT
'@
 Invoke-VMScript -VM $vmname -GuestCredential $Credential -ScriptText $initialize 
 Write-Host "New harddisk of $vmname initialized..." -BackgroundColor Green -ForegroundColor Black
 
 ######Creating new simple volume for disk######
 Write-Host "Creating new volume for new harddisk of $vmname..." -BackgroundColor Yellow -ForegroundColor Black
 ###CHANGE DISK NUMBER & DRIVE LETTER###
 $volume = @'
 New-Partition –DiskNumber 1 -UseMaximumSize -DriveLetter E | Format-Volume -FileSystem NTFS -Confirm:$false
'@
 Invoke-VMScript -VM $vmname -GuestCredential $Credential -ScriptText $volume
 Write-Host "Partition of new harddisk on $vmname created..." -BackgroundColor Green -ForegroundColor Black
 } 
 
} 

