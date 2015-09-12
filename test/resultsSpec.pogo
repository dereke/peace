httpism  = require 'httpism'
runTests = require './runTestsInPeace'
browser  = require 'browser-monkey'
get(server, url)=
  httpism.get! "http://localhost:#(server.data.port)#(url)".body

agent = require '../agent/agent'
testDiv()=
  container = document.getElementById('peace-test-container')
  if (container)
    container.parentNode.removeChild(container)
  else
    container :=document.createElement('div')
    container.id = 'peace-test-container'
    document.body.appendChild(container)

  container

describe 'results'
  it 'displays pass and failure' =>
    self.timeout 5000
    div = testDiv()
    runTests! {
      'goodAndBadSpec.js' = "
        describe('goodJS', function(){
          it('shouldPass', function(){
            console.log('ran with no errors');
          });
          it('shouldFail', function(){
            throw new Error('This test fails');
          });
        });"
      } (agent = false) @(server)
      peaceUrl = encodeURIComponent("http://localhost:#(server.data.port)")
      agent(
        div
        "/proxy/#(peaceUrl)"
        "ws://localhost:#(server.data.port)"
        {src = 'goodAndBadSpec.js', name = 'goodJS.shouldPass'}
      )
      peace = browser.component({
        title()=
          this.find('h1')

        results()=
          this.find('.results')
      })
      peace.title().shouldHave! {text = 'The peaceful test runner'}
      peace.results().shouldHave! {text = 'Passed'}
