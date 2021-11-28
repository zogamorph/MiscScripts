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

function get-sqlGeometryWKT
{
	param(
		[Parameter(Mandatory=$true, ValueFromPipeline=$true)]
		[string]$areaPolygonString
	)
	$returnString = $null
	$polygonPoints = $areaPolygonString.Split(",", [System.StringSplitOptions]::RemoveEmptyEntries )
	if( $polygonPoints.Count -gt 0){
	 	
		$sqlGemoertyBuilder = New-Object Microsoft.SqlServer.Types.SqlGeometryBuilder
		$sqlGemoertyBuilder.SetSrid(27700)
		$sqlGemoertyBuilder.BeginGeometry( [Microsoft.SqlServer.Types.OpenGisGeometryType]::Polygon) 
		$finshedfirstPoint = $false
		
		for ($i = 0; $i -lt $polygonPoints.Count; $i++)
		{
			$currentPoint = $polygonPoints[$i].Replace("((","(").Replace("))",")").Trim()
			if ( $currentPoint -ne [System.String]::Empty -and $currentPoint -ne "(" -and $currentPoint -ne ")" )
			{
				$currentPointStep = $i % 3 
				switch ($currentPointStep)
				{
					0 { $y = $polygonPoints[$i].Replace("(",""); break}
					
					1 { $x = $polygonPoints[$i] ; break }
					
					2 { if(-not $finshedfirstPoint)	
						{
							$startx = $x
							$starty = $y
							$sqlGemoertyBuilder.BeginFigure($x,$y)
							$finshedfirstPoint = $true
						}
						else
						{
							$sqlGemoertyBuilder.AddLine($x,$y)
							$endx = $x
							$endy = $y
						}
					}
				}
			}
	 		if($endx -ne $startx -and $endy -ne $starty )
			{
				$sqlGemoertyBuilder.AddLine($startx, $starty)
			}	
	 	}
		
		$sqlGemoertyBuilder.EndFigure()
		$sqlGemoertyBuilder.EndGeometry()
		$sqlGemoerty = $sqlGemoertyBuilder.ConstructedGeometry
		if ($sqlGemoerty.STIsValid() -eq $false) 
		{
				$sqlGemoerty = $sqlGemoerty.MakeValid() 
		}		
		$returnString = $sqlGemoerty.ToString()
	} 
	return $returnString
}

Import-Csv -Path c:\FileDump\PostCode.csv | Select-Object areaname,areapolygon,postalsector | ForEach-Object {  $objPostCode = $_
											$objPostCode.areapolygon =	get-sqlGeometryWKT -areaPolygonString $objPostCode.areapolygon 
											$objPostCode
} | Export-Csv -Path 'C:\FileDump\postcodesclean.csv' -NoTypeInformation