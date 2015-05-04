log     = (require 'debug') 'doom:server:test'
fsTree  = require 'fs-tree'
fs      = require 'fs-promise'
tmp     = require 'tmp'
httpism = require 'httpism'


httpClient = httpism.api 'http://localhost:8765/'

describe 'server'
  context 'first run'
    testFolder = nil
    server     = nil

    beforeEach
      testFolder := tmp.dir!(^)
      log "Setting up test folder #(testFolder)"
      fsTree! (testFolder) {
        test = {
          'oneSpec.js' = "describe('one', function(){
                            it('first', function(){})
                            it('second', function(){})
                          });"
          'twoSpec.js' = "describe('two', function(){
                            it('third', function(){throw new Error('oh crap')})
                            it('fourth', function(){})
                          });"
        }
      }

      server := (require '../lib/server')(testFolder).listen(8765)

    afterEach
      if (testFolder)
        fs.remove!(testFolder)
        log "Temp folder removed #(testFolder)"

      if (server)
        log "Stopping server"
        promise @(success)
          server.close(success)


    it.only 'returns all the tests as available jobs'
      jobs = httpClient.get!('jobs').body
      log('Jobs', jobs)

      expect(jobs).to.containSubset [
        'one.first'
        'one.second'
        'two.third'
        'two.fourth'
      ]
