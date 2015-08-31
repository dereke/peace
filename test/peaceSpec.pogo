httpism = require 'httpism'
censeo  = (require 'censeo/client')(8765)

describe 'peace'
  server = nil

  get(url)=
    httpism.get! "http://localhost:#(server.data.port)#(url)".body

  runTests(testFiles, exec)=
    server := censeo.runTask!(context: {testFiles = testFiles})
      launch  = serverRequire './server/launch'
      tmp     = serverRequire 'tmp'
      fsTree  = serverRequire 'fs-tree'

      testPath = tmp.dir!(^)
      fsTree! (testPath, testFiles)

      launchResult = launch!(testPath)
      {
        stop()=
          launchResult.stop!()
          fs = serverRequire 'fs-promise'
          fs.remove!(testPath)

        data = {
          port = launchResult.port
        }
      }

    try
      exec!()
    finally
      server.stop!()


  describe 'runs javascript tests'
    it 'runs a passing test' =>
      self.timeout 5000
      runTests! {
          'goodSpec.js' = "
            describe('goodJS', function(){
              it('shouldPass', function(){
                console.log('ran with no errors');
              });
            });"
        }
        retry!(timeout = 4000, interval = 500)
          result = get! "/results/goodJS.shouldPass"
          expect(result.passed).to.equal(true)


    it 'runs a failing test' =>
      self.timeout 5000
      runTests! {
        'badSpec.js' = "
            describe('badJS', function(){
              it('shouldFail', function(){
                throw new Error('This test fails');
              });
            });"
        }
        retry!(timeout = 4000, interval = 500)
          result = get! "/results/badJS.shouldFail"
          expect(result.passed).to.be.false
          expect(result.error.message).to.equal('This test fails')

  describe 'runs pogo tests'
    it 'runs a passing test' =>
      self.timeout 5000
      runTests! {
        'myPogoSpec.pogo' = "
describe 'goodPogo'
  it 'shouldPass'
    console.log 'ran with no errors'
  "
      }
        retry!(timeout = 4000, interval = 500)
          result = get! "/results/goodPogo.shouldPass"
          expect(result.passed).to.be.true

    it 'runs a failing test' =>
      self.timeout 5000
      runTests! {
        'myPogoSpec.pogo' = "
describe 'badPogo'
  it 'shouldFail'
    throw(new(Error('This test fails')))
  "
      }
        retry!(timeout = 4000, interval = 500)
          result = get! "/results/badPogo.shouldFail"
          expect(result.passed).to.be.false
