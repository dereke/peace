window.myLogger = require 'debug'
log     = window.myLogger 'peace:agent'
ajax    = require 'promjax'
socketIO= require 'socket.io-client'
plastiq = require 'plastiq'
h       = plastiq.html
testFullTitle = require('../server/testFullTitle')

window.addEventListener 'load'
  socket = socketIO.connect(window.location.origin)
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
          test  = e.detail.test
          error = e.detail.error
          ajax! {
            url    = '/result'
            method = 'PUT'
            data   = JSON.stringify({
              name   = testFullTitle(test)
              passed = !error
              error  = error
            })
            headers = {
              'content-type' = 'application/json'
            }
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
