log           = (require 'debug')('peace:qo')
pogo          = require 'pogo'
pogoify       = require 'pogoify'
glob          = require 'glob'
browserifyInc = require 'browserify-incremental'
chokidar      = require 'chokidar'
fs            = require 'fs-promise'
command       = require 'command-promise'

task 'build'
  fs.mkdirp! 'dist'
  bundle(source, destination)=
    log "Bundling #(source)"
    complete()=
      log "Bundled #(source)"

    b = browserifyInc {
      cache           = {}
      packageCache    = {}
      fullPaths       = true
      extensions      = ['.pogo']
      cacheFile       = './browserify-cache.json'
    }
    b.add(source)
    b.transform (pogoify)
    b.bundle().on('end', complete).pipe(fs.createWriteStream(__dirname+destination))

  bundleAll()=
    bundle('./agent/agent', '/dist/agent.js')
    bundle('./agent/mocha-reporter', '/dist/mocha-reporter.js')
    bundle('./agent/log', '/dist/log.js')
    //bundle('./agent/run', '/dist/run.js')

  compileAll()=
    files = glob!('./server/*.pogo', ^)
    for each @(file) in (files)
      pogo.compileFile!(file)

    log 'Pogo compiled'

  compilePogo(file)=
    pogo.compileFile!(file)
    log "#(file) compiled"

  chokidar.watch('agent/*').on('change', bundleAll).on('add', bundleAll).on('remove', bundleAll)
  chokidar.watch('server/*.pogo').on('change', compilePogo).on('add', compilePogo) 

  bundleAll!()
  compileAll!()

