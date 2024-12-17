#############################
# this job download backup files from Key vault, upload to blob storage
#
# use Managed Indentity
# require Key Vault Administrator role in key vault
# require storage blob data contributor role in storage account
#
#############################

# parameters
$kv_name = "gz-kv-trail-000001"

$storageAccountName = "gztrailstorageacct00001"
$storageAccountRG = "gz-trail"

$subfolder_dateString = Get-Date -Format "yyyyMMddHHmmssff"
$bk_path = "$($env:TEMP)\KVBK$($subfolder_dateString)"
$tags = @{"source"="keyvaultbackupjob";"from"="automation account name here"}

# output parameter value for reference
Write-output ">>>>>>>>>>>>>>>>>>==================== parameters  "
write-output "KV name: $kv_name"
write-output "Storage account: $storageAccountName"
write-output "backup temp folder: $bk_path"
Write-output ">>>>>>>>>>>>>>>>>>==================== parameters END"

Write-output ">>>>>>>>>>>>>>>>>>==================== Login  "
try
{   
    Connect-AzAccount -Identity | Out-Null
}
catch {
    Write-Error -Message $_.Exception
    throw $_.Exception
}
Write-output ">>>>>>>>>>>>>>>>>>==================== Login END "

# backup key vault, backup files to temp folder
Write-output "get objects from keyvault $($kv_name)"
$keys = Get-AzKeyVaultKey -VaultName $kv_name
$secrets = Get-AzKeyVaultSecret  -VaultName $kv_name
$certs = Get-AzKeyVaultCertificate  -VaultName $kv_name

$cert_names = @()
foreach ($cert in $certs) {   
    $cert_names += $cert.Name
}

Write-output ">>>>>>>>>>>>>>>>>>==================== backup start "
#prepare backup folder
Write-Output "==> prepare backup folder" 
if (-Not (Test-Path -Path $bk_path)) {
    try{
        New-Item -ItemType Directory -Path $bk_path
    }
    catch {
        Write-Error -Message $_.Exception
        throw $_.Exception
    }
}

#download backups
foreach ($cert in $certs) {  
        Write-Output "backup cert - $($cert.Name)" 
        $this_cert_bk_file_name = Join-Path -Path $bk_path -ChildPath "c-$($cert.Name)"
        Backup-AzKeyVaultCertificate -VaultName $kv_name -Name $cert.Name -OutputFile $this_cert_bk_file_name       
}

foreach ($key in $keys) {   
    if ($key.Name -in $cert_names){
        #Write-Output "this is cert, skip $($key.Name)" 
    }
    else {
        Write-Output "backup key - $($key.Name)" 
        $this_key_bk_file_name = Join-Path -Path $bk_path -ChildPath "k-$($key.Name)"
        Backup-AzKeyVaultKey -VaultName $kv_name -Name $key.Name -OutputFile $this_key_bk_file_name
    }    
}

foreach ($secret in $secrets) {   
    if ($secret.Name -in $cert_names){
        #Write-Output "this is cert, skip $($secret.Name)" 
    }
    else {
        Write-Output "backup secret - $($secret.Name)" 
        $this_sec_bk_file_name = Join-Path -Path $bk_path "s-$($secret.Name)"
        Backup-AzKeyVaultSecret -VaultName $kv_name -Name $secret.Name -OutputFile $this_sec_bk_file_name 
    }  
}
Write-output ">>>>>>>>>>>>>>>>>>====================  backup END "

# push backup files to storage account
Write-output ">>>>>>>>>>>>>>>>>>==================== upload start "

$blob_container_name = "$kv_name-$subfolder_dateString"  #TODO: verify its length 3 to 63

Write-Output "create target container: $($blob_container_name)"

$storageAccount = Get-AzStorageAccount -ResourceGroupName $storageAccountRG -Name $storageAccountName
$containerCtx = $storageAccount.Context
$container = New-AzStorageContainer -Name $blob_container_name -Context $containerCtx | Out-Null
#add tag to container, not working
# $container.BlobContainerClient.SetTags($tags)

#upload files, with tags  
$files = Get-ChildItem -Path $bk_path
foreach($file in $files){   
    Write-Output "upload $($file.BaseName)" 
    Set-AzStorageBlobContent -File $file.FullName -Container $blob_container_name -Context $containerCtx -Tag $tags  -Force | Out-Null
}

Write-output ">>>>>>>>>>>>>>>>>>==================== upload END "

# cleanup folder and files
Write-output ">>>>>>>>>>>>>>>>>>==================== clean up start "
try{
    Remove-Item -Path $bk_path -Recurse -Force
    if (-Not (Test-Path -Path $bk_path)) {
        write-output "backup folder removed."
    }
}
catch {
    Write-Error -Message $_.Exception
    throw $_.Exception
}

Write-output ">>>>>>>>>>>>>>>>>>==================== clean up END "

Write-output ">>>>>>>>>>>>>>>>>>=====Job completed==========<<<<<<<<<<<<<<<<< "
