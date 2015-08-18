#!/usr/bin/env node
var censeo = require('censeo').server
var launch = require('../server/launch');
var options = {
  port: 8765,
  configure: function(httpServer, socketServer){
    httpServer.on('connection', function connectionInterceptor(stream){
      stream.setTimeout(5000);
    });
    censeo(socketServer);
  }
};

launch(__dirname, options);
