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

  xdescribe 'comments', ->
    it 'only tokenizes comments that start at the beginning of a line', ->
      {tokens} = grammar.tokenizeLine '  //A comment?'

      expect(tokens[0]).toEqual value: '//', scopes: ['source.sass', 'comment.line.sass', 'punctuation.definition.comment.sass']
      expect(tokens[1]).toEqual value: 'A comment?', scopes: ['source.sass', 'comment.line.sass']

      {tokens} = grammar.tokenizeLine '/* also a comment */'

      expect(tokens[0]).toEqual value: '/*', scopes: ['source.sass', 'comment.block.sass', 'punctuation.definition.comment.sass']
      expect(tokens[1]).toEqual value: ' also a comment ', scopes: ['source.sass', 'comment.block.sass']
      expect(tokens[2]).toEqual value: '*/', scopes: ['source.sass', 'comment.block.sass', 'punctuation.definition.comment.sass']

      {tokens} = grammar.tokenizeLine 'hi //Not a comment'

      expect(tokens[3]).not.toEqual value: '//', scopes: ['source.sass', 'comment.line.sass', 'punctuation.definition.comment.sass']

      {tokens} = grammar.tokenizeLine 'hi /* also not a comment */'
      expect(tokens[3]).not.toEqual value: '/*', scopes: ['source.sass', 'comment.block.sass', 'punctuation.definition.comment.sass']

    it 'correctly tokenizes block comments based on indentation', ->
      tokens = grammar.tokenizeLines '''
        /* hi1
          hi2
        hi3
      '''

      expect(tokens[0][0]).toEqual value: '/*', scopes: ['source.sass', 'comment.block.sass', 'puncutation.definition.comment.sass']
      expect(tokens[0][1]).toEqual value: ' hi1', scopes: ['source.sass', 'comment.block.sass']
      expect(tokens[1][0]).toEqual value: '  hi2', scopes: ['source.sass', 'comment.block.sass']
      expect(tokens[2][0]).not.toEqual value: 'hi3', scopes: ['source.sass', 'comment.block.sass']

    it 'correctly tokenizes line comments based on indentation', ->
      tokens = grammar.tokenizeLines '''
        // hi1
          hi2
        hi3
      '''

      expect(tokens[0][0]).toEqual value: '//', scopes: ['source.sass', 'comment.line.sass', 'puncutation.definition.comment.sass']
      expect(tokens[0][1]).toEqual value: ' hi1', scopes: ['source.sass', 'comment.line.sass']
      expect(tokens[1][0]).toEqual value: '  hi2', scopes: ['source.sass', 'comment.line.sass']
      expect(tokens[2][0]).not.toEqual value: 'hi3', scopes: ['source.sass', 'comment.line.sass']
