log    = (require 'debug') 'doom:jobFinder:test'
fsTree = require 'fs-tree'
fs     = require 'fs-promise'
tmp    = require 'tmp'

describe 'jobFinder'
  context 'multiple files with multipe tests in a test direcotry'
    testFolder = nil
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

    afterEach
      if (testFolder)
        fs.remove!(testFolder)
        log "Temp folder removed #(testFolder)"

    it 'returns a list of all the tests that are ready to be run'
      jobFinder = require '../lib/jobFinder'
      results = jobFinder!(testFolder)
      expect(results.length).to.equal(4)
      expect(results).to.containSubset [
        'one.first'
        'one.second'
        'two.third'
        'two.fourth'
      ]
