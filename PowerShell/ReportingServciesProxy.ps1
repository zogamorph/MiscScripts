$URI = "http://ldnswright2/reportserver2008/ReportService2005.asmx?wsdl"
$rs = New-WebServiceProxy -Uri $URI -UseDefaultCredential

$rs.GetProperties ("/AgencyLeagueTablesReports/Data Sources",$retrieveProp)