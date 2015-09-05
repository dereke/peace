log        = (require 'debug') 'peace:server'
express    = require 'express'
cors       = require 'cors'
bodyParser = require 'body-parser'
compression = require 'compression'
path       = require 'path'
jobFinder  = require './jobFinder'
pogoify    = require 'pogoify'
glob       = require 'glob'
http          = require 'http'
socketIO      = require 'socket.io'

distPath = path.resolve(__dirname, '../dist')

module.exports(testsFolder)=
  console.log("Initialising server with folder #(testsFolder)")
  results = {}
  jobs    = nil
  availableJobs = []


  app = express()
  app.use(compression())
  app.use(cors())
  httpServer   = http.createServer(app)
  socketServer = socketIO(httpServer)

  app.get '/init' @(req, res)
    log 'Init received'
    if (!jobs)
      jobs          := jobFinder!(testsFolder)

    availableJobs := jobs.slice(0)

    log 'Init complete'
    log "#(availableJobs.length) jobs available"
    res.send('done')

  socketServer.on 'error' @(error)
    log('Socket Error', error)

  socketServer.on 'connection' @(socket)
    log 'agent connected'
    socket.on 'ready-for-job' @(data)
      log 'agent ready'
      job = availableJobs.shift()
      if (job)
        log 'agent sent job'
        socket.emit('job', job)

    socket.on 'result' @(result)
      log("Results received for #(result.name), passed: #(result.passed)")
      results.(result.name) = result

  app.get '/agent' @(req, res)
    res.send "
      <html>
      <head>
        <script src='/agent.js'></script>
      </head>
      <body></body>
      </html>
    "

  app.get '/agent.js' @(req, res)
    res.sendFile("#(distPath)/agent.js")

  app.get '/results/:name' @(req, res)
    result = results.(req.params.name) || {state = 'execution-pending'}

    log "result requested for #(req.params.name) - run: #(JSON.stringify(result))"

    res.header("Cache-Control", "no-cache, no-store, must-revalidate")
    res.header("Pragma", "no-cache")
    res.header("Expires", 0)

    log "Results requested for #(req.params.name)"
    res.send(result)

  app.get '/results' @(req, res)
    res.header("Cache-Control", "no-cache, no-store, must-revalidate")
    res.header("Pragma", "no-cache")
    res.header("Expires", 0)
    res.send(results)


  app.get '/runner' @(req, res)
    src = decodeURIComponent(req.query.src)
    res.send "<html>
                <body>
                  <div id='mocha'></div>
                  <script src='/runner/log.js'></script>
                  <script src='/runner/mocha.js'></script>
                  <script src='/runner/mocha-reporter.js'></script>
                  <script>mocha.setup({ui: 'bdd', reporter: Remote})</script>
                  <script src='/runner/test?src=#(src)'></script>
                  <script>mocha.run();</script>
                </body>
              </html>"

/*
//this is a test version trying to browserify mocha.. it doesn't work at the moment due to the way mocha is assembled
  app.get '/runner' @(req, res)
    src = decodeURIComponent(req.query.src)
    res.send "<html>
                <body>
                  <div id='mocha'></div>
                  <script src='/runner/run.js'></script>
                </body>
              </html>"

  app.get '/runner/run.js' @(req, res)
    res.sendFile("#(distPath)/run.js")

*/
  app.get '/runner/mocha.js' @(req, res)
    res.sendFile("#(path.resolve(__dirname, '../'))/node_modules/mocha/mocha.js")

  app.get '/runner/mocha-reporter.js' @(req, res)
    res.sendFile("#(distPath)/mocha-reporter.js")

  app.get '/runner/log.js' @(req, res)
    res.sendFile("#(distPath)/log.js")

  app.get '/runner/test' @(req, res)
    browserify = require 'browserify'
    b = browserify({transform = pogoify, extensions = ['.pogo']})
    globals = glob!("#(testsFolder)/global.+(js|pogo)", ^)
    b.add(globals)
    b.add("#(testsFolder)/#(decodeURIComponent(req.query.src))")
    b.bundle().pipe(res)

  app.get '/runner/deps' @(req, res)
    f = "#(testsFolder)/#(decodeURIComponent(req.query.src))"
    mdeps = require 'module-deps'
    JSONStream = require 'JSONStream'
    md = mdeps()
    md.pipe(JSONStream.stringify()).pipe(res)
    md.write(f)
    md.end()

  {
    http   = httpServer
    socket = socketServer
  }
