# delete service if it already exists
if (Get-Service filebeat -ErrorAction SilentlyContinue) {
  $service = Get-WmiObject -Class Win32_Service -Filter "name='filebeat'"
  $service.StopService()
  Start-Sleep -s 1
  $service.delete()
}

$workdir = Split-Path $MyInvocation.MyCommand.Path

# create new service
New-Service -name filebeat `
  -displayName filebeat `
  -binaryPathName "`"$workdir\\filebeat.exe`" -c `"$workdir\\filebeat.yml`""
