log = (require 'debug') 'doom:server'
server = require './server'
port = process.env.PORT || 7777

server("#(process.cwd())/test-example").listen(port)
log "Service started on port #(port)"
