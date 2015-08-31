socketIO= require 'socket.io-client'
plastiq = require 'plastiq'
h       = plastiq.html
require './log'
testFullTitle = require('../server/testFullTitle')

window.addEventListener 'load'
  socket = socketIO.connect(window.location.origin)
  socket.on 'error' @(error)
    console.log('error', error)

  socket.on 'connect'
    console.log 'connected to server'
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
      model.refresh = plastiq.html.refresh

      job = model.job
      console.log('Running job', job)
      h(
        'div'
        h.window({
          ontestcomplete(e)=
            console.log('result incoming from iframe')
            test  = e.detail.test
            error = e.detail.error
            socket.emit 'result' {
              name   = testFullTitle(test)
              passed = !error
              error  = error
            }

            console.log('complete', model.job)
            model.job = nil
            model.readyForJob()
            model.refresh()

        })
        h('h1', 'The peaceful test runner')
        if (job)
          h(
            'div'
            h('h2', 'Running job: ', job.name, ' from: ', job.src)
            h(
              'iframe'
              {src = "/runner/?src=#(encodeURIComponent(job.src))&grep=#(job.name)"}
            )
          )
        else
          h('div', 'No jobs to run at the moment')
      )

    plastiq.append(document.body, render, createModel())
