log   = (require 'debug') 'peace:jobFinder'
error = (require 'debug') 'peace:jobFinder:error'
Mocha = require 'mocha'
glob  = require 'glob'
path  = require 'path'
pogo  = require 'pogo'
testFullTitle = require './testFullTitle'

module.exports(testsPath)=
  mocha = new(Mocha({}))
  log "Get tests in path #(testsPath)"
  files = glob!("#(testsPath)/**/*.+(js|pogo)", ^)

  requireAny(file)=
    if(r/\.pogo$/.test(file))
      try
        pogo.run file(file) in module(module)!
      catch(e)
        error("running pogo #(file)", e, e.stack)
    else
      require(file)

  for each @(file) in (files)
    log "Add file #(file)"
    mocha.files.push(file)
    suite = mocha.suite
    suite.emit('pre-require', global, file, mocha)
    suite.emit('require', requireAny!(file), file, mocha)
    suite.emit('post-require', global, file, mocha)
    log "Added file #(file)"

  log "All files loaded"

  tests = []
  mocha.suite.eachTest @(test)
    log "each test #(test)"
    tests.push {
      src  = path.relative(testsPath, test.file)
      name = testFullTitle(test)
    }

  tests
