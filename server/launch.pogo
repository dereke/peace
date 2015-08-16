log           = (require 'debug') 'peace:launch'
createServer  = require './server'
launchBrowser = require 'firefox-launch'
httpism       = require 'httpism'
http          = require 'http'

module.exports(testFolder, port, censeo)=
    log "Launching server for folder #(testFolder) on port #(port)"
    server = http.createServer(createServer(testFolder))

    if (censeo)
      censeo(server)

    promise @(success)
      browser = nil

      server.on 'listening'
        log "peace is listening on port #(port)"
        httpism.get!("http://localhost:#(port)/init", {agent = false})
        browser := launchBrowser "http://localhost:#(port)/agent"

        stopServer()=
          promise @(success)
            server.unref()
            browser.kill()
            server.close(success)

        success(stopServer)
 
      server.listen(port)
