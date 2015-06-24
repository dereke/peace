log        = (require 'debug') 'doom:server'
express    = require 'express'
bodyParser = require 'body-parser'
compression = require 'compression'
path       = require 'path'
jobFinder  = require './jobFinder'

distPath = path.resolve(__dirname, '../dist')

module.exports(testsFolder)=
  log("Initialising server with folder #(testsFolder)")
  results = {}
  jobs    = nil
  availableJobs = []

  app = express()
  app.use(compression())

  app.get '/init' @(req, res)
    log 'Init received'
    if (!jobs)
      jobs          := jobFinder!(testsFolder)

    availableJobs := jobs.slice(0)

    log 'Init complete'
    log "#(availableJobs.length) jobs available"
    res.send('done')

  app.get '/job' @(req, res)
    job = availableJobs.shift()
    if (job)
      res.send(job)
    else
      res.status(200).end()

  app.get '/agent' @(req, res)
    res.send "
      <html>
      <head>
        <script defer src='/agent.js'></script>
      </head>
      <body></body>
      </html>
    "

  app.get '/agent.js' @(req, res)
    res.sendFile("#(distPath)/agent.js")

  app.get '/results/:name' @(req, res)
    log "Results requested for #(req.params.name)"
    res.send(results.(req.params.name))

  app.get '/results' @(req, res)
    res.send(results)

  app.put ('/result', bodyParser.json()) @(req, res)
    log("Results received for #(req.body.name), passed: #(req.body.passed)")
    results.(req.body.name) = {
      passed = req.body.passed
    }
    res.status(200).end()

  app.get '/runner' @(req, res)
    src = decodeURIComponent(req.query.src)
    res.send "<html>
                <body>
                  <div id='mocha'></div>
                  <script src='/runner/mocha.js'></script>
                  <script src='/runner/mocha-reporter.js'></script>
                  <script>mocha.setup({ui: 'bdd', reporter: Remote})</script>
                  <script src='/runner/test?src=#(src)'></script>
                  <script>mocha.run();</script>
                </body>
              </html>"

  app.get '/runner/mocha.js' @(req, res)
    res.sendFile("#(path.resolve(__dirname, '../'))/node_modules/mocha/mocha.js")

  app.get '/runner/mocha-reporter.js' @(req, res)
    res.sendFile("#(distPath)/mocha-reporter.js")

  app.get '/runner/test' @(req, res)
    browserify = require 'browserify'
    b = browserify()
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
