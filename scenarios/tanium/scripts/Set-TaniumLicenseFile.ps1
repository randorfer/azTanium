Param($Uri,$OutFile)
Invoke-WebRequest -OutFile $OutFile -Uri $Uri
Restart-Service 'Tanium Server'