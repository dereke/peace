#!/usr/bin/env node
var censeo = require('censeo').server
var launch = require('../server/launch');

var options = {
  port: 8765,
  configure: function(httpServer, socketServer){
    censeo(socketServer);
  }
};

launch(__dirname, options);
