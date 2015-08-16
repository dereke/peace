#!/usr/bin/env node
var censeo = require('censeo').server.listen
var launch = require('../server/launch');
launch(__dirname, 8765, censeo);
