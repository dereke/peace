/*<!--
<script src='/runner/mocha.js'></script>
<script src='/runner/mocha-reporter.js'></script>
<script>mocha.setup({ui: 'bdd', reporter: Remote})</script>
<script src='/runner/test?src=#(src)'></script>
<script>mocha.run();</script>-->*/
qs(name)=
  name      := name.replace(r/[\[]/, "\\[").replace(r/[\]]/, "\\]")
  regex     = new(RegExp("[\\?&]#(name)=([^&#]*)"))
  results   = regex.exec(location.search)
  if (results && results.1)
     decodeURIComponent(results.1.replace(r/\+/g, " "))
  else
    ''


process.stdout = {}
Mocha = require 'mocha'
reporter = require './mocha-reporter'

mocha = new(Mocha({
  ui = 'bdd'
  delay = true
  reporter = reporter
  files = ["/runner/test?src=#(qs('src'))"]
}))
mocha.suite.emit('pre-require', window, null, mocha)

console.log 'setup'
testScript = document.createElement('script')
testScript.type = 'text/javascript'
testScript.onload()=
  console.log 'run'
  debugger
  mocha.run()

testScript.src = "/runner/test?src=#(qs('src'))"
console.log 'added'
document.getElementsByTagName('head').0.appendChild(testScript)
