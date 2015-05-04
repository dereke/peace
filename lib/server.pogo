log     = (require 'debug') 'doom:server'
express = require 'express'
jobFinder = require './jobFinder'


module.exports(testsFolder)=
  app = express()

  app.get '/jobs' @(req, res)
    jobs = jobFinder!(testsFolder)
    res.send(jobs)


