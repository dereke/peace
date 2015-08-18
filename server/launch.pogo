debug         = require 'debug'
log           = (require 'debug') 'peace:launch'
createServer  = require './server'
launchBrowser = require 'chrome-launch'
httpism       = require 'httpism'

module.exports(testFolder, options)=
    port        = options.port
    configure   = options.configure

    log "Launching server for folder #(testFolder) on port #(port)"
    server = createServer(testFolder)
    httpServer = server.http
    socketServer = server.socket

    socketServer.on 'connection' @(socket)
      socket.on 'log' @(logEntry)
        (debug("peace:#(logEntry.source)")).apply(debug, logEntry.args)

    if (configure)
      configure(httpServer, socketServer)

    promise @(success)
      httpServer.on 'listening'
        log "peace is listening on port #(port)"
        httpism.get!("http://localhost:#(port)/init", {agent = false})
        browser = launchBrowser("http://localhost:#(port)/agent")
        log "Browser opened"

        stopAll(done)=

          browser.on 'close'
            log 'browser closed'
            httpServer.on 'close'
              log 'server closed'
              done(true)

            httpServer.unref()
            httpServer.close()

          browser.kill()

        success(stopAll)
 
      httpServer.on 'error' @(e)
        if (e.code == 'EADDRINUSE')
          ++port
          httpServer.listen(port)
        else
          throw(e)

      httpServer.listen(port)
