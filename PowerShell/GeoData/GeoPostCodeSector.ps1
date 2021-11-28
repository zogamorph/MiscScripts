<#
.SYNOPSIS
   <A brief description of the script>
.DESCRIPTION
   <A detailed description of the script>
.PARAMETER <paramName>
   <Description of script parameter>
.EXAMPLE
   <An example of using the script>
#>

Add-Type -Path 'C:\Program Files (x86)\Microsoft SQL Server\110\SDK\Assemblies\Microsoft.SqlServer.Types.dll'

function get-sqlGeographyWKT
{
	param(
		[Parameter(Mandatory=$true, ValueFromPipeline=$true)]
		[xml]$geometryXML 
	)
	
	$polygon = $geometryXML.Polygon
	$returnString = $null
	$sqlGeographyBuilder = New-Object Microsoft.SqlServer.Types.SqlGeographyBuilder
	$sqlGeographyBuilder.SetSrid(4326)
		
	if( $polygon -ne $null) 
	{
	
		$sqlGeographyBuilder.BeginGeography( [Microsoft.SqlServer.Types.OpenGisGeographyType]::Polygon) 
		$pointsLists = $polygon.outerBoundaryIs.LinearRing.coordinates.Split(" ")
		$finshedfirstPoint = $false
		foreach($currentPoint in $pointsLists)
		{
			$point = $currentPoint.Split(",")
			if(-not $finshedfirstPoint)	
			{
				$startLat = $point[1]
				$startLong = $point[0]
				$sqlGeographyBuilder.BeginFigure($point[1],$point[0])
				$finshedfirstPoint = $true
			}
			else
			{
				$sqlGeographyBuilder.AddLine($point[1],$point[0])
				$endLat = $point[1]
				$endLong = $point[0]
			}
		}
		
		if($endLat -ne $startLat -and $endLong -ne $startLong )
		{
			$sqlGeographyBuilder.AddLine($startLat, $startLong)
		}
		
		$sqlGeographyBuilder.EndFigure()
		$sqlGeographyBuilder.EndGeography()
		$sqlGeography = $sqlGeographyBuilder.ConstructedGeography
		
		if($sqlGeography.STIsValid() -eq $false)
		{
			$sqlGeography = $sqlGeography.MakeValid()
		}
		
		if($sqlGeography.EnvelopeAngle() -gt 90) 
		{
			$sqlGeography = $sqlGeography.ReorientObject()
		}
	}
	else 
	{	
		$sqlGeographyBuilder.BeginGeography( [Microsoft.SqlServer.Types.OpenGisGeographyType]::Point) 
		$point = $geometryXML.Point.coordinates.Split(",")		
		$startLat = $point[1]
		$startLong = $point[0]
		$sqlGeographyBuilder.BeginFigure($point[1],$point[0])
		$sqlGeographyBuilder.EndFigure()
		$sqlGeographyBuilder.EndGeography()
		$sqlGeography = $sqlGeographyBuilder.ConstructedGeography
		
	}
	
	$returnString = $sqlGeography.ToString()
	return $returnString
	
}


Import-Csv -Path 'c:\FileDump\UKPostcodeSectors.csv' | ForEach-Object { $objUKPostcodeSector = $_ 
	 [XML]$geometryXML = $objUKPostcodeSector.geometry
	 $objUKPostcodeSector.geometry  =  get-sqlGeographyWKT -geometryXML $geometryXML
	 $objUKPostcodeSector
} | Export-Csv -Path 'C:\FileDump\UKPostcodeSectorsClean.csv' -NoTypeInformation