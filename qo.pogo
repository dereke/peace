log           = (require 'debug')('doom:qo')
pogoify       = require 'pogoify'
browserifyInc = require 'browserify-incremental'
watch         = require 'node-watch'
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
    bundle('./lib/agent', '/dist/agent.js')
    bundle('./lib/mocha-reporter', '/dist/mocha-reporter.js')

  watch('lib', bundleAll)
  bundleAll()

