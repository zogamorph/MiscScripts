$reportServerOutput = "C:\powershell\Report.html"

if(Test-Path $reportServerOutput)
{
     Remove-Item $reportServerOutput
}

$r = [System.Net.WebRequest]::Create("http://uksqlprd106/reports")
$credcache = [System.Net.CredentialCache]::DefaultCredentials
$r.Credentials = $credcache
$resp = $r.GetResponse()
$reqstream = $resp.GetResponseStream()
$sr = new-object System.IO.StreamReader $reqstream
$sr.ReadToEnd()| Out-File -FilePath $reportServerOutput 