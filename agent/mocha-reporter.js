var Base = require('mocha/lib/reporters/base');
window.Remote = Remote;

function Remote(runner) {
  Base.call(this, runner);

  var self = this;

  runner.on('start', function(){
    window.parent.dispatchEvent(new CustomEvent('teststarting'));
  });

  runner.on('pending', function(test){
    window.parent.dispatchEvent(new CustomEvent('testpending', { detail: test }));
  });

  runner.on('pass', function(test){
    window.parent.dispatchEvent(new CustomEvent('testcomplete', { detail: test }));
  });

  runner.on('fail', function(test, err){
    window.parent.dispatchEvent(new CustomEvent('testcomplete', { detail: test }));
  });

  runner.on('end', function(){
    window.parent.dispatchEvent(new CustomEvent('testended'));
    self.epilogue();
  });
}

Remote.prototype.__proto__ = Base.prototype;