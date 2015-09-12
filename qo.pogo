log           = (require 'debug')('peace:qo')
pogo          = require 'pogo'
pogoify       = require 'pogoify'
glob          = require 'glob'
browserify    = require 'browserify'
chokidar      = require 'chokidar'
fs            = require 'fs-promise'
command       = require 'command-promise'

task 'build'
  fs.mkdirp! 'dist'
  bundle(source, destination, options)=
    options := options || {}
    log "Bundling #(source)"
    complete()=
      log "Bundled #(source)"

    b = browserify {
      fullPaths       = true
      extensions      = ['.pogo']
      alias           = options.alias
      standalone      = options.standalone
    }
    b.add(source)
    b.transform (pogoify)
    b.bundle().on('end', complete).pipe(fs.createWriteStream(__dirname+destination))

  bundleAll()=
    bundle('./agent/agent', '/dist/agent.js', {standalone = 'startAgent'})
    bundle('./agent/mocha-reporter', '/dist/mocha-reporter.js')
    bundle('./agent/log', '/dist/log.js')

/*
    bundle('./agent/run', '/dist/run.js', {
      alias = ['node_modules/mocha/lib/mocha.js:./lib-cov/mocha']
  })
*/

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

