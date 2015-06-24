#!/usr/bin/env pogo
path = require 'path'
testFolder = path.resolve(process.cwd(), process.argv.2)
port       = process.argv.3 || 8765

if (!testFolder)
  console.log 'Must supply a folder to the tests'

server = (require '../lib/server')(testFolder).listen(port)

