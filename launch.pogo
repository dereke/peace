log     = (require 'debug') 'doom:launch'
createServer = require './lib/server'
launch      = require 'firefox-launch'
httpism = require 'httpism'
http = require 'http'

module.exports(testFolder, port)=
    log "Launching server for folder #(testFolder) on port #(port)"
    server = http.createServer(createServer(testFolder))

    promise @(success)
      browser = nil

      server.on 'listening'
        log "Doom listening on port #(port)"
        httpism.get!("http://localhost:#(port)/init", {agent = false})
        browser := launch "http://localhost:#(port)/agent"

        stopServer()=
          promise @(success)
            server.unref()
            browser.kill()
            server.close(success)

        success(stopServer)
 
      server.listen(8765)
