SorcuePath = 'C:\Projects\3D' 
$TargetPath = 'C:\temp\test' 
$excludePaths = 'Binaries','Releases','TeamBuildProcessTemplates','Branches', 'Build' , "Resharper"


Get-ChildItem -Path $SorcuePath -Recurse | % {  
     if(! $_.PSIsContainer)  
     {   
          $currentItem = $_   
          $skipItem = $false   
          
          foreach($excludePath in $excludePaths)   
          {    
               if($_.DirectoryName.ToLower().Contains($excludePath.ToLower()))    
               {     $skipItem = $true     
                       Break   
               }   
            }      
          if(!$skipItem)   
          {    
               $itemDestination = $_.FullName.ToLower().Replace($SorcuePath.ToLower(),$TargetPath.ToLower())        
               
               if (!(Test-Path -Path (Split-Path -Parent $itemDestination))) 
               {     
                        New-Item -Type Directory -Path $(Split-Path -Parent -Path $itemDestination)    
                }    
                
                try    
               {     
                    Copy-Item -Path $currentItem.FullName -Destination $itemDestination -ErrorAction Stop        
               }    
               catch    
               {     
                    Write-Host $currentItem.FullName     
                    Write-Host $itemDestination    
                 }   
          }        
     } 
}