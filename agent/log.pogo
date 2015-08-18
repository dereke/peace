logToSocket = require 'log-to-socket'
qs(name)=
  name      := name.replace(r/[\[]/, "\\[").replace(r/[\]]/, "\\]")
  regex     = new(RegExp("[\\?&]#(name)=([^&#]*)"))
  results   = regex.exec(location.search)
  if (results.1)
     decodeURIComponent(results.1.replace(r/\+/g, " "))
  else
    ''

console.log('Log interception about to commence')
logToSocket({
  url = window.location.origin
  sourceName = "#(qs('src')):#(qs('grep'))"
})
