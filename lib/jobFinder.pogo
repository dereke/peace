log   = (require 'debug') 'doom:jobFinder'
Mocha = require 'mocha'
glob  = require 'glob'

fullTitle(test)=
  path = []
  while(test.parent != nil)
    path.unshift(test.title)
    test := test.parent

  path.join '.'

module.exports(testsPath)=
  log "Get tests in path #(testsPath)"
  files = glob!("#(testsPath)/**/*Spec.js", ^)

  mocha = new(Mocha({}))
  for each @(file) in (files)
    log "Add file #(file)"
    mocha.addFile(file)

  mocha.loadFiles()

  tests = []
  mocha.suite.eachTest @(test)
    tests.push(fullTitle(test))

  tests
