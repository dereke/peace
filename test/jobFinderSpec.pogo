log    = (require 'debug') 'peace:jobFinder:test'
censeo  = (require 'censeo/client')(8765)

describe 'jobFinder'
  context 'multiple files with multipe tests in a test direcotry'
    testFolder = nil
    beforeEach
      testFolder := censeo.run!()
        fsTree = serverRequire 'fs-tree'
        tmp    = serverRequire 'tmp'
        testFolder := tmp.dir!(^)
        console.log "Setting up test folder #(testFolder)"
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

        testFolder

    afterEach
      if (testFolder)
        censeo.run!(context = {testFolder = testFolder})
          fs = serverRequire 'fs-promise'
          fs.remove!(testFolder)
          console.log "Temp folder removed #(testFolder)"

    it 'returns a list of all the tests that are ready to be run'
      results = censeo.run!(context = {testFolder = testFolder})
        jobFinder = serverRequire './server/jobFinder'
        jobFinder!(testFolder)

      expect(results.length).to.equal(4)
      expect(results).to.containSubset [
        { name = 'one.first',  src = 'test/oneSpec.js' }
        { name = 'one.second', src = 'test/oneSpec.js' }
        { name = 'two.third',  src = 'test/twoSpec.js' }
        { name = 'two.fourth', src = 'test/twoSpec.js' }
      ]
