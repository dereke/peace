#!/usr/bin/env node
var censeo = require('censeo').server
var launch = require('../server/launch');
var debug = require('debug');

var options = {
  port: 8765,
  configure: function(httpServer, socketServer){
    socketServer.on('connection', function(socket){
      socket.on('log', function(logEntry){
        console.log.apply(console, logEntry.args)
        //debug('peace:test:'+logEntry.source, logEntry.args);
      })
    });
    censeo(socketServer);
  }
};

launch(__dirname, options);
