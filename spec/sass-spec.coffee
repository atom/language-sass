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

  describe 'vendor-prefixed properties', ->
    it 'tokenizes them as properties', ->
      tokens = grammar.tokenizeLines '''
        .something
          -webkit-mask-repeat: no-repeat
      '''

      expect(tokens[1][1]).toEqual value: '-webkit-mask-repeat', scopes: ['source.sass', 'meta.property-name.sass', 'support.type.property-name.css.sass']

  describe 'numbers', ->
    it 'tokenizes them', ->
      tokens = grammar.tokenizeLines '''
        .something
          top: 50%
      '''

      expect(tokens[1][4]).toEqual value: '50', scopes: ['source.sass', 'meta.property-name.sass', 'meta.property-value.sass', 'constant.numeric.css']

    it 'tokenizes number operations', ->
      tokens = grammar.tokenizeLines '''
        .something
          top: +50%
      '''

      expect(tokens[1][4]).toEqual value: '+', scopes: ['source.sass', 'meta.property-name.sass', 'meta.property-value.sass', 'keyword.operator.css']
      expect(tokens[1][5]).toEqual value: '50', scopes: ['source.sass', 'meta.property-name.sass', 'meta.property-value.sass', 'constant.numeric.css']

      tokens = grammar.tokenizeLines '''
        .something
          top: 50% - 30%
      '''

      expect(tokens[1][7]).toEqual value: '-', scopes: ['source.sass', 'meta.property-name.sass', 'meta.property-value.sass', 'keyword.operator.css']

  describe 'variables', ->
    it 'tokenizes them', ->
      {tokens} = grammar.tokenizeLine '$test: bla'

      expect(tokens[0]).toEqual value: '$', scopes: ['source.sass', 'meta.variable-declaration.sass', 'punctuation.definition.entity.sass']
      expect(tokens[1]).toEqual value: 'test', scopes: ['source.sass', 'meta.variable-declaration.sass', 'variable.other.sass']
      expect(tokens[2]).toEqual value: ':', scopes: ['source.sass', 'meta.variable-declaration.sass', 'punctuation.separator.operator.sass']
      expect(tokens[3]).toEqual value: ' ', scopes: ['source.sass', 'meta.variable-declaration.sass', 'meta.property-value.sass']
      expect(tokens[4]).toEqual value: 'bla', scopes: ['source.sass', 'meta.variable-declaration.sass', 'meta.property-value.sass']

    it 'tokenizes indented variables', ->
      {tokens} = grammar.tokenizeLine '  $test: bla'

      expect(tokens[1]).toEqual value: '$', scopes: ['source.sass', 'meta.variable-declaration.sass', 'punctuation.definition.entity.sass']
      expect(tokens[2]).toEqual value: 'test', scopes: ['source.sass', 'meta.variable-declaration.sass', 'variable.other.sass']
      expect(tokens[3]).toEqual value: ':', scopes: ['source.sass', 'meta.variable-declaration.sass', 'punctuation.separator.operator.sass']
      expect(tokens[4]).toEqual value: ' ', scopes: ['source.sass', 'meta.variable-declaration.sass', 'meta.property-value.sass']
      expect(tokens[5]).toEqual value: 'bla', scopes: ['source.sass', 'meta.variable-declaration.sass', 'meta.property-value.sass']

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
