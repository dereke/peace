window.myLogger = require 'debug'
log     = window.myLogger 'doom:agent'
ajax    = require 'promjax'
plastiq = require 'plastiq'
h       = plastiq.html
testFullTitle = require('./testFullTitle')

window.addEventListener 'load'
  createModel()=
    model = {
      getNewJob()=
        response = ajax! {
          url           = '/job'
        }

        console.log(response)
        if (response)
          JSON.parse(response)
    }
    setInterval
      if (!model.job)
        model.job = model.getNewJob!()
        model.refresh()
    100

    model

  render(model)=
    model.refresh = plastiq.html.refresh


    job = model.job
    console.log('Running job', job)
    h(
      'div'
      h.window({
        ontestcomplete(e)=
          test = e.detail
          ajax! {
            url    = '/result'
            method = 'PUT'
            data   = JSON.stringify({
              name   = testFullTitle(test)
              passed = test.state == 'passed'
            })
            headers = {
              'content-type' = 'application/json'
            }
          }

          console.log('complete', model.job)
          model.job = model.getNewJob!()
          model.refresh()

      })
      h('h1', 'Welcome to the test runner of doom!')
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
