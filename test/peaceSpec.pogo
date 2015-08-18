log     = (require 'debug') 'peace:test:peace'
if (log.enable)
  log.enable('*')

reqwest = require 'reqwest'
port = 8765

censeo  = (require 'censeo/client')(port)
get(url)=
  reqwest! { url = "http://localhost:8766#(url)" }

xdescribe 'basic'
  it 'does'
   expect(1).to.equal(1)

describe 'peace'
  testFolder = nil
  serverTask = nil

  beforeEach
    serverTask := nil

    testFolder := censeo.run!()
      tmp     = serverRequire 'tmp'
      tmp.dir!(^)

  afterEach
    if (serverTask)
      serverTask.stop!()
      console.log('stopped each')

    if (testFolder)
      censeo.run!(context: {testFolder = testFolder})
        fs = require 'fs-promise'
        fs.remove!(testFolder)
        console.log "Temp folder removed #(testFolder)"


  context 'runs tests'
    beforeEach
      console.log "launch peace on port #(port)"
      serverTask := censeo.runTask!(context: {port = port, testFolder = testFolder})
        console.log "launching on port #(port)"
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
        stopServer = launch!(testFolder, {port = port})
        {
          stop(done)=
            stopServer(done)
        }
      
    it 'runs a passing test and gives results indicating a pass' =>
      self.timeout 10000 
      retry!(timeout = 10000, interval = 500)
        result = get! "/results/one.first"
        expect(result.passed).to.be.true

    it 'runs a failing test and gives results indicating a pass' =>
      self.timeout 10000
      retry!(timeout = 10000, interval = 500)
        result = get! "/results/one.second"
        expect(result.passed).to.be.false
        expect(result.error.message).to.equal('This test fails')

  context 'runs pogo tests'
    beforeEach
      serverTask := censeo.runTask!(context: {port = port, testFolder = testFolder})
        launch  = serverRequire './server/launch'
        fsTree  = require 'fs-tree'
        fsTree! (testFolder) {
          test = {
            'myPogoSpec.pogo' = "
describe 'pogo'
  it 'first'
    console.log 'ran with no errors'

  it 'second'
    throw(new(Error('This test fails')))
  "
          }
        }
        stopServer = launch!(testFolder, {port = port})
        {
          stop(done)=
            stopServer(done)
        }


    it 'runs a passing test and gives results indicating a pass' =>
      self.timeout 5000
      retry!(timeout = 4000, interval = 500)
        result = get! "/results/pogo.first"
        expect(result.passed).to.be.true

    xit 'runs a failing test and gives results indicating a pass' =>
      self.timeout 5000
      retry!(timeout = 4000, interval = 500)
        result = get! "/results/pogo.second"
        expect(result.passed).to.be.false
