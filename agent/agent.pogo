socketIO= require 'socket.io-client'
plastiq = require 'plastiq'
h       = plastiq.html
http    = require 'httpism'
testFullTitle = require('../server/testFullTitle')
logToServer = require './log'

module.exports(container, httpUrl, socketUrl, initialJob)=
  debugger
  httpUrl := httpUrl || window.location.origin
  socketUrl := socketUrl || httpUrl

  socket = socketIO(socketUrl)
  logToServer(socketUrl)

  socket.on 'error' @(error)
    console.log('error', error)

  socket.on 'disconnect' @(e)
    console.log('disconnected')

  socket.on 'connect'
    console.log "Agent connected to server #(httpUrl)"
    createModel()=
      model = {
        results = []
        readyForJob()=
          socket.emit('ready-for-job')
      }

      socket.on 'job' @(job)
        model.job = job
        model.refresh()

      socket.on 'result' @(result)
        model.results.push(result)
        model.refresh()

      if (initialJob)
        model.job = initialJob
      else
        model.readyForJob()

      model

    render(model)=
      try
        model.refresh = plastiq.html.refresh

        job = model.job
        h(
          'div'
          h('h1', 'The peaceful test runner')
          h(
            'ul.results'
            model.results.map @(result)
              h(
                'li'
                h('a', {href = "#(httpUrl)/runner/?src=#(encodeURIComponent(result.src))&grep=#(encodeURIComponent(result.name))", target= "_blank"}, result.name)
                ' '
                if (result.passed)
                  'Passed'
                else
                  'Failed'
              )
          )
          if (!job)
            h('div', 'No jobs to run at the moment')

          if (job)
            h(
              'div'
              h('h2', 'Running job: ', job.name, ' from: ', job.src)
              h.window({
                ontestcomplete(e)=
                  try
                    test  = e.detail.test
                    error = e.detail.error
                    passed = !error

                    console.log("#(test.state.toUpperCase()): #( model.job.name)")
                    if (error)
                      console.log(error)

                    socket.emit 'result' {
                      name   = testFullTitle(test)
                      src    = job.src
                      passed = passed
                      error  = error
                    }
                    model.job = nil
                    model.readyForJob()
                  catch(e)
                    console.log("AGENT: ERROR #(e)")
              })

              h(
                'iframe'
                {
                  src = "#(httpUrl)/runner/?src=#(encodeURIComponent(job.src))&grep=#(encodeURIComponent(job.name))"
                  width = '100%'
                  height = '100%'
                }
              )
            )
        )
      catch(e)
        console.log('AGENTERROR', e)
        h('div', e)

    plastiq.append(container, render, createModel())
