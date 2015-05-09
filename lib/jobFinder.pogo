log   = (require 'debug') 'doom:jobFinder'
Mocha = require 'mocha'
glob  = require 'glob'
path  = require 'path'
testFullTitle = require './testFullTitle'


module.exports(testsPath)=
  mocha = new(Mocha({}))
  log "Get tests in path #(testsPath)"
  files = glob!("#(testsPath)/**/*.js", ^)

  for each @(file) in (files)
    log "Add file #(file)"
    mocha.addFile(file)

  mocha.loadFiles()

  tests = []
  mocha.suite.eachTest @(test)
    log "each test #(test)"
    tests.push {
      src  = path.relative(testsPath, test.file)
      name = testFullTitle(test)
    }

  tests
