httpism  = require 'httpism'
runTests = require './runTestsInPeace'

get(server, url)=
  httpism.get! "http://localhost:#(server.data.port)#(url)".body

describe 'runTests'
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
        } @(server)
        retry!(timeout = 4000, interval = 500)
          result = get! (server) "/results/goodJS.shouldPass"
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
        } @(server)
        retry!(timeout = 4000, interval = 500)
          result = get! (server) "/results/badJS.shouldFail"
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
      } @(server)
        retry!(timeout = 4000, interval = 500)
          result = get! (server) "/results/goodPogo.shouldPass"
          expect(result.passed).to.be.true

    it 'runs a failing test' =>
      self.timeout 5000
      runTests! {
        'myPogoSpec.pogo' = "
describe 'badPogo'
  it 'shouldFail'
    throw(new(Error('This test fails')))
  "
      } @(server)
        retry!(timeout = 4000, interval = 500)
          result = get! (server) "/results/badPogo.shouldFail"
          expect(result.passed).to.be.false
