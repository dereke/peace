chai   = require 'chai'
chai.use(require 'chai-subset')

global.expect = chai.expect
global.retry  = require 'trytryagain'
