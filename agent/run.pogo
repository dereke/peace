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
  if (results)
     decodeURIComponent(results[1].replace(r/\+/g, " "))
  else
    ''


console.log 'pre moch'
mocha = require 'mocha/lib/mocha'
console.log 'post moch'
reporter = require './mocha-reporter'
console.log 'repo'

mocha.setup({ui = 'bdd', reporter})
console.log 'setup'
testScript = document.createElement('script')
testScript.onload()=
  console.log 'run' 
  mocha.run()

testScript.src = "/runner/test?src=#(qs('src'))"
console.log 'added'
document.getElementsByTagName('script').0.parentNode.appendChild(testScript)
