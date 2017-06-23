
  param($IncludeAzure)

  if($IncludeAzure){
	Get-Command *DSC*
  }else{
	Get-Command *DSC*|Where {-not ($_.Source -match 'Azure')}
  }

