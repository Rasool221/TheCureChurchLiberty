sub Init() 
  m.top.functionName = "getStatus"
end sub

sub getStatus()
  request = CreateObject("roUrlTransfer")
  
  request.SetCertificatesFile("common:/certs/ca-bundle.crt")
  request.SetUrl("https://cdn3.wowza.com/1/Y0xKNkMxM000bnFk/d0FQMXZJ/hls/live/playlist.m3u8")
  request.EnableHostVerification(false)
  request.EnablePeerVerification(false)
  
  response = request.GetToString()

  print "***Response***: " + response

  if response.Len() > 0 then
    m.top.isOnline = "true"
  else 
    m.top.isOnline = "false"
  endif
  

  print "Set m.top.isOnline to: " + m.top.isOnline
end sub