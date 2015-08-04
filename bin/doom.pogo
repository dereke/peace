#!/usr/bin/env pogo
if (!process.argv.2)
  console.log 'Must supply a path to the tests'
  return

path       = require 'path'
launch     = require '../launch'
testFolder = path.resolve(process.cwd(), process.argv.2)
port       = process.argv.3 || 8765


launch!(testFolder, port)

