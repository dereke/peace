censeo  = (require 'censeo/client')(8765)

module.exports(testFiles, agent: true, exec)=
  server = censeo.runTask!(context: {testFiles = testFiles, agent = agent})
    launch  = serverRequire './server/launch'
    tmp     = serverRequire 'tmp'
    fsTree  = serverRequire 'fs-tree'

    testPath = tmp.dir!(^)
    fsTree! (testPath, testFiles)

    launchResult = launch!(testPath, agent = agent)
    {
      stop()=
        launchResult.stop!()
        fs = serverRequire 'fs-promise'
        fs.remove!(testPath)

      data = {
        port = launchResult.port
      }
    }

  try
    exec!(server)
  finally
    server.stop!()
