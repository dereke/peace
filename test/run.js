#!/usr/bin/env node
var censeo = require('censeo').server
var launch = require('../server/launch');
var httpProxy = require('http-proxy');
var proxy = httpProxy.createProxyServer({});

proxy.on('error', function(e){
  console.log('Proxy error', e);
});

var options = {
  port: 8765,
  configure: function(httpServer, socketServer, app){
    censeo(socketServer);

    app.use('/proxy/:url', function(req, res){
      proxy.web(req, res, { target: decodeURIComponent(req.params.url) });
    });
  }
};

launch(__dirname, options);
