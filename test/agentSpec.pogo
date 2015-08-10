log     = (require 'debug') 'doom:agent:test'
fsTree  = require 'fs-tree'
fs      = require 'fs-promise'
tmp     = require 'tmp'
httpism = require 'httpism'
launch  = require '../launch'

testPort   = 8765
httpClient = httpism.api "http://localhost:#(testPort)"

describe 'agent'
  testFolder = nil
  stopServer = nil

  beforeEach
    log('testFolder', testFolder)
    testFolder := tmp.dir!(^)

  afterEach
    if (testFolder)
      fs.remove!(testFolder)
      log "Temp folder removed #(testFolder)"

    if (stopServer)
      stopServer!()

  context 'runs tests'
    beforeEach
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

      stopServer := launch!(testFolder, testPort)
      
    it 'runs a passing test and gives results indicating a pass' =>
      self.timeout 5000 
      log 'starting test'
      retry!(timeout = 4000, interval = 500)
        result = httpClient.get! "results/one.first"
        expect(result.body.passed).to.be.true

    it 'runs a failing test and gives results indicating a pass' =>
      self.timeout 5000
      retry!(timeout = 4000, interval = 500)
        result = httpClient.get! "results/one.second"
        expect(result.body.passed).to.be.false

  context 'runs pogo tests'
    beforeEach
      fsTree! (testFolder) {
        test = {
          'myPogoSpec.pogo' = "
describe 'pogo'
  it 'first'
    console.log('ran with no errors')

  it 'second'
    throw(new(Error('This test fails')))
"
        }
      }
      stopServer := launch!(testFolder, testPort)


    it 'runs a passing test and gives results indicating a pass' =>
      self.timeout 5000
      log 'starting test'
      retry!(timeout = 4000, interval = 500)
        result = httpClient.get! "results/pogo.first"
        expect(result.body.passed).to.be.true

    it 'runs a failing test and gives results indicating a pass' =>
      self.timeout 5000
      retry!(timeout = 4000, interval = 500)
        result = httpClient.get! "results/pogo.second"
        expect(result.body.passed).to.be.false
