socketIO= require 'socket.io-client'
plastiq = require 'plastiq'
h       = plastiq.html
http = require 'httpism'
require './log'
testFullTitle = require('../server/testFullTitle')

window.addEventListener 'load'
  socket = socketIO.connect(window.location.origin)
  socket.on 'error' @(error)
    console.log('error', error)

  socket.on 'disconnect' @(e)
    console.log('DISCONNECT')

  socket.on 'connect'
    console.log 'Agent connected to server'
    createModel()=
      model = {
        readyForJob()=
          socket.emit('ready-for-job')
      }

      socket.on 'job' @(job)
        model.job = job
        model.refresh()

      model.readyForJob()
      model

    render(model)=
      try
        model.refresh = plastiq.html.refresh

        job = model.job
        h(
          'div'
          h('h1', 'The peaceful test runner')
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
                {src = "/runner/?src=#(encodeURIComponent(job.src))&grep=#(encodeURIComponent(job.name))"}
              )
            )
          else
            h('div', 'No jobs to run at the moment')
        )
      catch(e)
        console.log('AGENTERROR', e)
        h('div', e)

    plastiq.append(document.body, render, createModel())
