log     = (require 'debug') 'peace:test:peace'
if (log.enable)
  log.enable('*')

reqwest = require 'reqwest'

censeo  = (require 'censeo').client(8765)
get(url)=
  reqwest! { url = "http://localhost:8766#(url)" }

xdescribe 'basic'
  it 'does'
   expect(1).to.equal(1)

describe 'peace'
  server = {
    port = 8766
  }
  testFolder = nil

  beforeEach
    server.testFolder := censeo.run!(promises: true)
      tmp     = serverRequire 'tmp'
      tmp.dir!(^)

    console.log('testFolder', server.testFolder)

  afterEach
    if (testFolder)
      censeo.run!(promises: true, context: server)
        fs = require 'fs-promise'
        fs.remove!(testFolder)
        log "Temp folder removed #(testFolder)"

    if (server.task)
      server.task.stop!()

  context 'runs tests'
    beforeEach
      server.task = censeo.runTask!(promises: true, context: server)
        launch  = serverRequire './server/launch'
        fsTree  = require 'fs-tree'
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
        stopServer = launch!(testFolder, port)
        {
          stop(done)=
            console.log 'stopping'
            stopServer!()
            console.log 'stopped'
            done()
        }
      
    it 'runs a passing test and gives results indicating a pass' =>
      self.timeout 10000 
      log 'starting test'
      retry!(timeout = 10000, interval = 500)
        result = get! "/results/one.first"
        expect(result.passed).to.be.true

    it 'runs a failing test and gives results indicating a pass' =>
      self.timeout 10000
      console.log 'aserting..'
      retry!(timeout = 10000, interval = 500)
        result = get! "/results/one.second"
        expect(result.passed).to.be.false
        expect(result.error.message).to.equal('This test fails')

  context 'runs pogo tests'
    beforeEach
      server.stop = censeo.runTask!(promises: true, context: server)
        launch  = serverRequire './server/launch'
        fsTree  = require 'fs-tree'
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
        stopServer = launch!(testFolder, port)
        {
          stop(done)=
            console.log 'stopping'
            stopServer!()
            console.log 'stopped'
            done()
        }


    xit 'runs a passing test and gives results indicating a pass' =>
      self.timeout 5000
      log 'starting test'
      retry!(timeout = 4000, interval = 500)
        result = get! "/results/pogo.first"
        expect(result.passed).to.be.true

    xit 'runs a failing test and gives results indicating a pass' =>
      self.timeout 5000
      retry!(timeout = 4000, interval = 500)
        result = get! "/results/pogo.second"
        expect(result.passed).to.be.false
