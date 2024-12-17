
#############   script to back up key vault keys/secrets     #############
$sub_name = "Visual Studio Enterprise Subscription - Gary Zhou"

$kv_name = "gz-kv-trail-000001"

$storageAccountName = "gztrailstorageacct00001"
$sasToken = "sv=2022-11-02&ss=b&srt=sco&sp=rwdlactfx&se=2025-12-13T02:28:08Z&st=2024-12-12T18:28:08Z&spr=https&sig=QCmJoPsAYVaUy5PwrHsupz6LgY%2FQv0FTVep4b57BGBI%3D"

$bk_base_path = "C:\temp\keyVaultbackup"


## log in
Write-Host "login to subscription $($sub_name)"
Connect-AzAccount -Subscription $sub_name
# Disconnect-AzAccount

#Write-Host "get list of resource group"
#Get-AzResourceGroup | select-object ResourceGroupName, Location


$subfolder_dateString = Get-Date -Format "yyyy-MM-dd-HH-mm-ss-ffff"
$bk_path =  Join-Path -Path $bk_base_path -ChildPath $subfolder_dateString
if (-Not (Test-Path -Path $bk_path)) {
    New-Item -ItemType Directory -Path $bk_path
}

Write-Host "get objects from keyvault $($kv_name)"
$keys = Get-AzKeyVaultKey -VaultName $kv_name
$secrets = Get-AzKeyVaultSecret  -VaultName $kv_name
$certs = Get-AzKeyVaultCertificate  -VaultName $kv_name

$cert_names = @()
foreach ($cert in $certs) {   
    $cert_names += $cert.Name
}
#$cert_names

Write-Host ">>>>>>>>>>>>>>>>>>==================== start backup"
$bk_cert_subfolder = $bk_path
foreach ($cert in $certs) {  
        Write-Output "backup cert - $($cert.Name)" 
        $this_cert_bk_file_name = Join-Path -Path $bk_cert_subfolder -ChildPath "cert-$($cert.Name)"
        Backup-AzKeyVaultCertificate -VaultName $kv_name -Name $cert.Name -OutputFile $this_cert_bk_file_name       
}

#Write-Host ">>>>>>>>>>>>>>>>>>===================="
$bk_key_subfolder = $bk_path
foreach ($key in $keys) {
    #Write-Output $key.Name
    if ($key.Name -in $cert_names){
        #Write-Output "this is cert, skip $($key.Name)" 
    }
    else {
        Write-Output "backup key - $($key.Name)" 
        $this_key_bk_file_name = Join-Path -Path $bk_key_subfolder -ChildPath "key-$($key.Name)"
        Backup-AzKeyVaultKey -VaultName $kv_name -Name $key.Name -OutputFile $this_key_bk_file_name
    }    
}

#Write-Host ">>>>>>>>>>>>>>>>>>===================="
$bk_secret_subfolder = $bk_path
foreach ($secret in $secrets) {   
    if ($secret.Name -in $cert_names){
        #Write-Output "this is cert, skip $($secret.Name)" 
    }
    else {
        Write-Output "backup secret - $($secret.Name)" 
        $this_sec_bk_file_name = Join-Path -Path $bk_secret_subfolder "secret-$($secret.Name)"
        Backup-AzKeyVaultSecret -VaultName $kv_name -Name $secret.Name -OutputFile $this_sec_bk_file_name 
    }  
}

Write-Host ">>>>>>>>>>>>>>>>>>====================  END "

Write-Host ">>>>>>>>>>>>>>>>>>====================  load to storage account "

#$testing_folder = "C:\temp\keyVaultbackup1\$subfolder_dateString"
$files = Get-ChildItem -Path $bk_path
$blob_container_name = "$kv_name-$subfolder_dateString"  # todo: verify its length 3 to 63

Write-Output "create target container $($blob_container_name)"
$containerCtx = New-AzStorageContext -StorageAccountName $storageAccountName -SasToken $sasToken
New-AzStorageContainer -Name $blob_container_name -Context $containerCtx | Out-Null

foreach($file in $files){   
    Write-Output "upload $($file.BaseName)" 
    Set-azstorageBlobContent -File $file.FullName -Container $blob_container_name -Context $containerCtx -Force  | Out-Null
}

Write-Host ">>>>>>>>>>>>>>>>>>====================  END "

