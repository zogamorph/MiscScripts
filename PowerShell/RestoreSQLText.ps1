$logfolderPath = "\\psukdmpprd101\SQLBackups-PRD1\Tape\PSUKSQLSTBY108_ShopProp\DBs\TRNLogs\shopproperty_statistics"
$lastRestoreDate = [datetime]::ParseExact ("20140923143000" ,"yyyyMMddHHmmss" ,$null )

Get-ChildItem -LiteralPath $logfolderPath | Sort-Object -Property LastWriteTime | Where-Object { ($_.PSIsContainer -eq $false ) -and ($_.LastWriteTime -gt $lastRestoreDate ) } | ForEach-Object {$currentFile = $_
                         $restoreCommand = "RESTORE LOG [shopproperty_statistics] FROM DISK = '{0}' WITH NORECOVERY" -f       $currentFile.fullName
                      $restoreCommand
} | Out-File c:\FileDump\SQL\Restore.sql