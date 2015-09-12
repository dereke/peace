debug         = require 'debug'
log           = (require 'debug') 'peace:launch'
createServer  = require './server'
launchBrowser = require 'chrome-launch'
httpism       = require 'httpism'
enableDestroy = require 'server-destroy'

module.exports(testFolder, port: 8765, agent: true, configure: @{})=
    log "Launching server for folder #(testFolder) on port #(port)"
    server = createServer(testFolder)
    app          = server.app
    httpServer   = server.http
    socketServer = server.socket

    enableDestroy(httpServer)
    socketServer.on('connection') @(socket)
      socket.on('log') @(logEntry)
        console.log.apply(console, logEntry.args)

    socketServer.on 'connection' @(socket)
      socket.on 'log' @(logEntry)
        (debug("peace:#(logEntry.source)")).apply(debug, logEntry.args)

    if (configure)
      configure(httpServer, socketServer, app)

    promise @(serverStarted)
      httpServer.on 'listening'
        log "peace is listening on port #(port)"
        httpism.get! "http://localhost:#(port)/init"
        tasks = []
        if (agent)
          browser = launchBrowser("http://localhost:#(port)/agent")
          log "Browser opened #(browser.pid)"

          tasks.push
            promise @(browserStopped)
              browser.on 'close'
                console.log 'Browser Closed'
                browserStopped()

              browser.kill()


        tasks.push
          promise @(serverStopped)
            httpServer.on 'close'
              console.log('Peace Stopped')
              serverStopped()

            httpServer.destroy()

        stopAll()=
          for each @(task) in (tasks)
            task!()

        console.log('Peace Started', port, testFolder)
        serverStarted {
          stop = stopAll
          port = port
        }

      httpServer.on 'error' @(e)
        if (e.code == 'EADDRINUSE')
          ++port
          httpServer.listen(port)
        else
          throw(e)

      httpServer.listen(port)
