module.exports(test)=
  testPath = []
  while(test.parent != nil)
    testPath.unshift(test.title)
    test := test.parent

  testPath.join '.'
