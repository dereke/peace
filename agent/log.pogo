logToSocket = require 'log-to-socket'
module.exports(url)=
  qs(name)=
    name      := name.replace(r/[\[]/, "\\[").replace(r/[\]]/, "\\]")
    regex     = new(RegExp("[\\?&]#(name)=([^&#]*)"))
    results   = regex.exec(location.search)
    if (results && results.1)
       decodeURIComponent(results.1.replace(r/\+/g, " "))
    else
      'agent'

  console.log('Log interception about to commence')
  logToSocket({
    url = url
    sourceName = "#(qs('src')):#(qs('grep'))"
  })
