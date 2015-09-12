log   = (require 'debug') 'peace:jobFinder'
error = (require 'debug') 'peace:jobFinder:error'
Mocha = require 'mocha/lib/mocha'
glob  = require 'glob'
path  = require 'path'
pogo  = require 'pogo'
testFullTitle = require './testFullTitle'

module.exports(testsPath)=
  mocha = new(Mocha({}))
  log "Get tests in path #(testsPath)"
  files = glob!("#(testsPath)/**/*.+(js|pogo)", ^)

  for each @(file) in (files)
    try
      log "Add file #(file)"
      mocha.files.push(file)
      suite = mocha.suite
      suite.emit('pre-require', global, file, mocha)
      suite.emit('require', require(file), file, mocha)
      suite.emit('post-require', global, file, mocha)
      log "Added file #(file)"
    catch(e)
      log "Failed to add file #(file) - #(e)"
      throw(e)

  log "All files loaded"

  tests = []
  mocha.suite.eachTest @(test)
    if (!test.pending)
      tests.push {
        src  = path.relative(testsPath, test.file)
        name = testFullTitle(test)
      }

  tests
