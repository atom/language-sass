describe 'SASS grammar', ->
  grammar = null

  beforeEach ->
    waitsForPromise ->
      atom.packages.activatePackage('language-sass')

    runs ->
      grammar = atom.grammars.grammarForScopeName('source.sass')

  it 'parses the grammar', ->
    expect(grammar).toBeTruthy()
    expect(grammar.scopeName).toBe 'source.sass'
