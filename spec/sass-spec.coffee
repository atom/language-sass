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

  describe 'comments', ->
    it 'only tokenizes comments that start at the beginning of a line', ->
      {tokens} = grammar.tokenizeLine '  //A comment?'

      expect(tokens[1]).toEqual value: '//', scopes: ['source.sass', 'comment.line.sass', 'punctuation.definition.comment.sass']
      expect(tokens[2]).toEqual value: 'A comment?', scopes: ['source.sass', 'comment.line.sass']

      {tokens} = grammar.tokenizeLine '/* also a comment */'

      expect(tokens[0]).toEqual value: '/*', scopes: ['source.sass', 'comment.block.sass', 'punctuation.definition.comment.sass']
      expect(tokens[1]).toEqual value: ' also a comment ', scopes: ['source.sass', 'comment.block.sass']
      expect(tokens[2]).toEqual value: '*/', scopes: ['source.sass', 'comment.block.sass', 'punctuation.definition.comment.sass']

      {tokens} = grammar.tokenizeLine 'this //is not a comment'

      expect(tokens[1]).toEqual value: '//is not a comment', scopes: ['source.sass', 'meta.selector.css', 'invalid.illegal.sass']

      {tokens} = grammar.tokenizeLine 'this /* is also not a comment */'
      expect(tokens[1]).toEqual value: '/* is also not a comment */', scopes: ['source.sass', 'meta.selector.css', 'invalid.illegal.sass']

    it 'correctly tokenizes block comments based on indentation', ->
      tokens = grammar.tokenizeLines '''
        /* hi1
          hi2
        hi3
      '''

      expect(tokens[0][0]).toEqual value: '/*', scopes: ['source.sass', 'comment.block.sass', 'punctuation.definition.comment.sass']
      expect(tokens[0][1]).toEqual value: ' hi1', scopes: ['source.sass', 'comment.block.sass']
      expect(tokens[1][0]).toEqual value: '  hi2', scopes: ['source.sass', 'comment.block.sass']
      expect(tokens[2][0]).not.toEqual value: 'hi3', scopes: ['source.sass', 'comment.block.sass']

    it 'correctly tokenizes line comments based on indentation', ->
      tokens = grammar.tokenizeLines '''
        // hi1
          hi2
        hi3
      '''

      expect(tokens[0][0]).toEqual value: '//', scopes: ['source.sass', 'comment.line.sass', 'punctuation.definition.comment.sass']
      expect(tokens[0][1]).toEqual value: ' hi1', scopes: ['source.sass', 'comment.line.sass']
      expect(tokens[1][0]).toEqual value: '  hi2', scopes: ['source.sass', 'comment.line.sass']
      expect(tokens[2][0]).not.toEqual value: 'hi3', scopes: ['source.sass', 'comment.line.sass']
