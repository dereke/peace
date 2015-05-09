log     = (require 'debug') 'doom:agent:test'
fsTree  = require 'fs-tree'
fs      = require 'fs-promise'
tmp     = require 'tmp'
launch  = require 'firefox-launch'
httpism = require 'httpism'

httpClient = httpism.api 'http://localhost:8765/'

describe 'agent'
  testFolder = nil
  browser    = nil
  server     = nil

  beforeEach      
    testFolder := tmp.dir!(^)
    server := (require '../lib/server')(testFolder).listen(8765)

  afterEach
    if (browser)
      browser.kill()

    if (testFolder)
      fs.remove!(testFolder)
      log "Temp folder removed #(testFolder)"

    if (server)
      log "Stopping server"
      promise @(success)
        server.close(success)

  context 'runs tests'
    beforeEach
      log('testFolder', testFolder)
      fsTree! (testFolder) {
        test = {
          'oneSpec.js' = "
                          describe('one', function(){
                            it('first', function(){
                              console.log('ran with no errors');
                            });
                            it('second', function(){
                              throw new Error('This test fails');
                            });
                          });"
        }
      }
      
    it 'runs a passing test and gives results indicating a pass' =>
      self.timeout 5000 
      browser := launch 'http://localhost:8765/agent'
      httpism.get! 'http://localhost:8765/init'
      retry!(timeout = 4000, interval = 500)
        result = httpClient.get! "results/one.first"
        expect(result.body.passed).to.be.true

    it 'runs a failing test and gives results indicating a pass' =>
      self.timeout 5000
      browser := launch 'http://localhost:8765/agent'
      httpism.get! 'http://localhost:8765/init'
      retry!(timeout = 4000, interval = 500)
        result = httpClient.get! "results/one.second"
        expect(result.body.passed).to.be.false
