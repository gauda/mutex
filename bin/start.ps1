# set "unrestricted" first:
# http://technet.microsoft.com/de-de/library/ee176961.aspx

$path = "notepad" # path to your tool
$url = 'http://examle.com/mutex'
$tenant = 1

# do not change anything below
$url = $url+'/'+$tenant
$req = [system.Net.WebRequest]::Create($url+"/set?user="+[Environment]::UserName)
try {
  $res = $req.GetResponse()
} catch [System.Net.WebException] {
  $res = $_.Exception.Response
}

if([int]$res.StatusCode -eq 200){
  echo "mutex has been set"
  start-process -wait $path
  $req = [system.Net.WebRequest]::Create($url+"/release?user="+[Environment]::UserName)
  try {
    $res = $req.GetResponse()
  } catch [System.Net.WebException] {
    $res = $_.Exception.Response
  }
}else{
  $web = New-Object Net.WebClient
  $web.DownloadString($url)
}
