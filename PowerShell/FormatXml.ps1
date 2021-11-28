function Format-Xml  {
    param($PathXML, $Indent=2, $Destination="$env:temp\out.xml", [switch]$Open)
    $xml = New-Object XML
    $xml.Load($PathXML)
    $StringWriter = New-Object System.IO.StringWriter
    $XmlWriter = New-Object System.XMl.XmlTextWriter $StringWriter
    $xmlWriter.Formatting = "indented"
    $xmlWriter.Indentation = $Indent
    $xml.WriteContentTo($XmlWriter)
    $XmlWriter.Flush()
    $StringWriter.Flush()
    Set-Content -Value ($StringWriter.ToString()) -Path $Destination
    if ($Open) { notepad $Destination }
} 



$LoadedAssemblies = [appdomain]:: currentdomain.getassemblies () | sort -property fullname #| format-table fullname