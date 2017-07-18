describe 'Sass grammar', ->
  grammar = null

  beforeEach ->
    waitsForPromise ->
      atom.packages.activatePackage('language-css')

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
      expect(tokens[1][1]).toEqual value: '-webkit-mask-repeat', scopes: ['source.sass', 'meta.property-name.sass', 'support.type.vendored.property-name.css']

  describe 'property-list', ->
    it 'tokenizes the property-name and property-value', ->
      tokens = grammar.tokenizeLines '''
        very-custom
          color: inherit
      '''
      expect(tokens[1][1]).toEqual value: 'color', scopes: ['source.sass', 'meta.property-name.sass', 'support.type.property-name.css']
      expect(tokens[1][2]).toEqual value: ':', scopes: ['source.sass', 'meta.property-value.sass', 'punctuation.separator.key-value.css']
      expect(tokens[1][3]).toEqual value: ' ', scopes: ['source.sass', 'meta.property-value.sass']
      expect(tokens[1][4]).toEqual value: 'inherit', scopes: ['source.sass', 'meta.property-value.sass', 'support.constant.property-value.css']

    it 'tokenizes nested property-lists', ->
      tokens = grammar.tokenizeLines '''
        very-custom
          very-very-custom
            color: inherit
          margin: top
      '''
      expect(tokens[2][1]).toEqual value: 'color', scopes: ['source.sass', 'meta.property-name.sass', 'support.type.property-name.css']
      expect(tokens[2][2]).toEqual value: ':', scopes: ['source.sass', 'meta.property-value.sass', 'punctuation.separator.key-value.css']
      expect(tokens[2][3]).toEqual value: ' ', scopes: ['source.sass', 'meta.property-value.sass']
      expect(tokens[2][4]).toEqual value: 'inherit', scopes: ['source.sass', 'meta.property-value.sass', 'support.constant.property-value.css']
      expect(tokens[3][1]).toEqual value: 'margin', scopes: ['source.sass', 'meta.property-name.sass', 'support.type.property-name.css']
      expect(tokens[3][2]).toEqual value: ':', scopes: ['source.sass', 'meta.property-value.sass', 'punctuation.separator.key-value.css']
      expect(tokens[3][3]).toEqual value: ' ', scopes: ['source.sass', 'meta.property-value.sass']
      expect(tokens[3][4]).toEqual value: 'top', scopes: ['source.sass', 'meta.property-value.sass', 'support.constant.property-value.css']

    it 'tokenizes colon-first property-list syntax', ->
      tokens = grammar.tokenizeLines '''
        very-custom
          :color inherit
      '''
      expect(tokens[1][1]).toEqual value: ':', scopes: ['source.sass', 'punctuation.separator.key-value.css']
      expect(tokens[1][2]).toEqual value: 'color', scopes: ['source.sass', 'meta.property-name.sass', 'support.type.property-name.css']
      expect(tokens[1][3]).toEqual value: ' ', scopes: ['source.sass', 'meta.property-value.sass']
      expect(tokens[1][4]).toEqual value: 'inherit', scopes: ['source.sass', 'meta.property-value.sass', 'support.constant.property-value.css']

    it 'tokenizes nested colon-first property-list syntax', ->
      tokens = grammar.tokenizeLines '''
        very-custom
          very-very-custom
            :color inherit
          :margin top
      '''
      expect(tokens[2][1]).toEqual value: ':', scopes: ['source.sass', 'punctuation.separator.key-value.css']
      expect(tokens[2][2]).toEqual value: 'color', scopes: ['source.sass', 'meta.property-name.sass', 'support.type.property-name.css']
      expect(tokens[2][3]).toEqual value: ' ', scopes: ['source.sass', 'meta.property-value.sass']
      expect(tokens[2][4]).toEqual value: 'inherit', scopes: ['source.sass', 'meta.property-value.sass', 'support.constant.property-value.css']
      expect(tokens[3][1]).toEqual value: ':', scopes: ['source.sass', 'punctuation.separator.key-value.css']
      expect(tokens[3][2]).toEqual value: 'margin', scopes: ['source.sass', 'meta.property-name.sass', 'support.type.property-name.css']
      expect(tokens[3][3]).toEqual value: ' ', scopes: ['source.sass', 'meta.property-value.sass']
      expect(tokens[3][4]).toEqual value: 'top', scopes: ['source.sass', 'meta.property-value.sass', 'support.constant.property-value.css']

  describe 'pseudo-classes and pseudo-elements', ->
    it 'tokenizes pseudo-classes', ->
      tokens = grammar.tokenizeLines '''
        a:hover
          display: none
      '''
      expect(tokens[0][0]).toEqual value: 'a', scopes: ['source.sass', 'meta.selector.css', 'entity.name.tag.css']
      expect(tokens[0][1]).toEqual value: ':', scopes: ['source.sass', 'meta.selector.css', 'entity.other.attribute-name.pseudo-class.css', 'punctuation.definition.entity.css']
      expect(tokens[0][2]).toEqual value: 'hover', scopes: ['source.sass', 'meta.selector.css', 'entity.other.attribute-name.pseudo-class.css']

    it 'tokenizes pseudo-elements', ->
      tokens = grammar.tokenizeLines '''
        a::before
          display: none
      '''

      expect(tokens[0][0]).toEqual value: 'a', scopes: ['source.sass', 'meta.selector.css', 'entity.name.tag.css']
      expect(tokens[0][1]).toEqual value: '::', scopes: ['source.sass', 'meta.selector.css', 'entity.other.attribute-name.pseudo-element.css', 'punctuation.definition.entity.css']
      expect(tokens[0][2]).toEqual value: 'before', scopes: ['source.sass', 'meta.selector.css', 'entity.other.attribute-name.pseudo-element.css']

    it 'tokenizes functional pseudo-classes', ->
      tokens = grammar.tokenizeLines '''
        &:not(.selected)
          display: none
      '''

      expect(tokens[0][1]).toEqual value: ':', scopes: ['source.sass', 'meta.selector.css', 'entity.other.attribute-name.pseudo-class.css', 'punctuation.definition.entity.css']
      expect(tokens[0][2]).toEqual value: 'not', scopes: ['source.sass', 'meta.selector.css', 'entity.other.attribute-name.pseudo-class.css']
      expect(tokens[0][3]).toEqual value: '(', scopes: ['source.sass', 'meta.selector.css', 'punctuation.section.function.begin.bracket.round.css']
      expect(tokens[0][4]).toEqual value: '.', scopes: ['source.sass', 'meta.selector.css', 'entity.other.attribute-name.class.css', 'punctuation.definition.entity.css']
      expect(tokens[0][5]).toEqual value: 'selected', scopes: ['source.sass', 'meta.selector.css', 'entity.other.attribute-name.class.css']
      expect(tokens[0][6]).toEqual value: ')', scopes: ['source.sass', 'meta.selector.css', 'punctuation.section.function.end.bracket.round.css']

    it 'tokenizes nested pseudo-classes', ->
      tokens = grammar.tokenizeLines '''
        body
          a:hover
            display: none
      '''
      expect(tokens[1][1]).toEqual value: 'a', scopes: ['source.sass', 'meta.selector.css', 'entity.name.tag.css']
      expect(tokens[1][2]).toEqual value: ':', scopes: ['source.sass', 'meta.selector.css', 'entity.other.attribute-name.pseudo-class.css', 'punctuation.definition.entity.css']
      expect(tokens[1][3]).toEqual value: 'hover', scopes: ['source.sass', 'meta.selector.css', 'entity.other.attribute-name.pseudo-class.css']

    it 'tokenizes nested pseudo-elements', ->
      tokens = grammar.tokenizeLines '''
        body
          a::before
            display: none
      '''
      expect(tokens[1][1]).toEqual value: 'a', scopes: ['source.sass', 'meta.selector.css', 'entity.name.tag.css']
      expect(tokens[1][2]).toEqual value: '::', scopes: ['source.sass', 'meta.selector.css', 'entity.other.attribute-name.pseudo-element.css', 'punctuation.definition.entity.css']
      expect(tokens[1][3]).toEqual value: 'before', scopes: ['source.sass', 'meta.selector.css', 'entity.other.attribute-name.pseudo-element.css']

  describe 'numbers', ->
    it 'tokenizes them', ->
      tokens = grammar.tokenizeLines '''
        .something
          top: 50%
      '''
      expect(tokens[1][4]).toEqual value: '50', scopes: ['source.sass', 'meta.property-value.sass', 'constant.numeric.css']

    it 'tokenizes number operations', ->
      tokens = grammar.tokenizeLines '''
        .something
          top: +50%
      '''
      expect(tokens[1][4]).toEqual value: '+50', scopes: ['source.sass', 'meta.property-value.sass', 'constant.numeric.css']

      tokens = grammar.tokenizeLines '''
        .something
          top: 50% - 30%
      '''
      expect(tokens[1][7]).toEqual value: '-', scopes: ['source.sass', 'meta.property-value.sass', 'keyword.operator.css']

  describe 'variables', ->
    it 'tokenizes them', ->
      {tokens} = grammar.tokenizeLine '$test: bla'

      expect(tokens[0]).toEqual value: '$', scopes: ['source.sass', 'meta.variable-declaration.sass', 'punctuation.definition.entity.sass']
      expect(tokens[1]).toEqual value: 'test', scopes: ['source.sass', 'meta.variable-declaration.sass', 'variable.other.sass']
      expect(tokens[2]).toEqual value: ':', scopes: ['source.sass', 'meta.variable-declaration.sass', 'meta.property-value.sass', 'punctuation.separator.key-value.css']
      expect(tokens[3]).toEqual value: ' ', scopes: ['source.sass', 'meta.variable-declaration.sass', 'meta.property-value.sass']
      expect(tokens[4]).toEqual value: 'bla', scopes: ['source.sass', 'meta.variable-declaration.sass', 'meta.property-value.sass']

    it 'tokenizes indented variables', ->
      {tokens} = grammar.tokenizeLine '  $test: bla'

      expect(tokens[1]).toEqual value: '$', scopes: ['source.sass', 'meta.variable-declaration.sass', 'punctuation.definition.entity.sass']
      expect(tokens[2]).toEqual value: 'test', scopes: ['source.sass', 'meta.variable-declaration.sass', 'variable.other.sass']
      expect(tokens[3]).toEqual value: ':', scopes: ['source.sass', 'meta.variable-declaration.sass', 'meta.property-value.sass', 'punctuation.separator.key-value.css']
      expect(tokens[4]).toEqual value: ' ', scopes: ['source.sass', 'meta.variable-declaration.sass', 'meta.property-value.sass']
      expect(tokens[5]).toEqual value: 'bla', scopes: ['source.sass', 'meta.variable-declaration.sass', 'meta.property-value.sass']

  describe 'strings', ->
    it 'tokenizes single-quote strings', ->
      tokens = grammar.tokenizeLines """
        .a
          content: 'hi'
      """
      expect(tokens[1][4]).toEqual value: "'", scopes: ['source.sass', 'meta.property-value.sass', 'string.quoted.single.sass', 'punctuation.definition.string.begin.sass']
      expect(tokens[1][5]).toEqual value: 'hi', scopes: ['source.sass', 'meta.property-value.sass', 'string.quoted.single.sass']
      expect(tokens[1][6]).toEqual value: "'", scopes: ['source.sass', 'meta.property-value.sass', 'string.quoted.single.sass', 'punctuation.definition.string.end.sass']

    it 'tokenizes double-quote strings', ->
      tokens = grammar.tokenizeLines '''
        .a
          content: "hi"
      '''
      expect(tokens[1][4]).toEqual value: '"', scopes: ['source.sass', 'meta.property-value.sass', 'string.quoted.double.sass', 'punctuation.definition.string.begin.sass']
      expect(tokens[1][5]).toEqual value: 'hi', scopes: ['source.sass', 'meta.property-value.sass', 'string.quoted.double.sass']
      expect(tokens[1][6]).toEqual value: '"', scopes: ['source.sass', 'meta.property-value.sass', 'string.quoted.double.sass', 'punctuation.definition.string.end.sass']

    it 'tokenizes escape characters', ->
      tokens = grammar.tokenizeLines """
        .a
          content: '\\abcdef'
      """
      expect(tokens[1][5]).toEqual value: '\\abcdef', scopes: ['source.sass', 'meta.property-value.sass', 'string.quoted.single.sass', 'constant.character.escape.sass']

      tokens = grammar.tokenizeLines '''
        .a
          content: "\\abcdef"
      '''
      expect(tokens[1][5]).toEqual value: '\\abcdef', scopes: ['source.sass', 'meta.property-value.sass', 'string.quoted.double.sass', 'constant.character.escape.sass']

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

  describe 'at-rules and directives', ->
    it 'tokenizes @function', ->
      {tokens} = grammar.tokenizeLine '@function function_name($p1, $p2)'
      expect(tokens[0]).toEqual value: '@', scopes: ['source.sass', 'meta.at-rule.function.sass', 'keyword.control.at-rule.function.sass', 'punctuation.definition.entity.sass']
      expect(tokens[1]).toEqual value: 'function', scopes: ['source.sass', 'meta.at-rule.function.sass', 'keyword.control.at-rule.function.sass']
      expect(tokens[3]).toEqual value: 'function_name', scopes: ['source.sass', 'meta.at-rule.function.sass', 'support.function.misc.sass']
      expect(tokens[5]).toEqual value: '$', scopes: ['source.sass', 'meta.at-rule.function.sass', 'meta.variable-usage.sass', 'punctuation.definition.entity.css']
      expect(tokens[6]).toEqual value: 'p1', scopes: ['source.sass', 'meta.at-rule.function.sass', 'meta.variable-usage.sass', 'variable.other.sass']
      expect(tokens[8]).toEqual value: '$', scopes: ['source.sass', 'meta.at-rule.function.sass', 'meta.variable-usage.sass', 'punctuation.definition.entity.css']
      expect(tokens[9]).toEqual value: 'p2', scopes: ['source.sass', 'meta.at-rule.function.sass', 'meta.variable-usage.sass', 'variable.other.sass']

    it 'tokenizes @return', ->
      {tokens} = grammar.tokenizeLine '@return \'border\' + \' \' + \'1px solid pink\''
      expect(tokens[0]).toEqual value: '@', scopes: ['source.sass', 'meta.at-rule.return.sass', 'keyword.control.return.sass', 'punctuation.definition.entity.sass']
      expect(tokens[1]).toEqual value: 'return', scopes: ['source.sass', 'meta.at-rule.return.sass', 'keyword.control.return.sass']
      expect(tokens[4]).toEqual value: 'border', scopes: ['source.sass', 'meta.at-rule.return.sass', 'string.quoted.single.sass']
      expect(tokens[7]).toEqual value: '+', scopes: ['source.sass', 'meta.at-rule.return.sass', 'keyword.operator.css']

    it 'tokenizes @if', ->
      {tokens} = grammar.tokenizeLine '@if $var == true'
      expect(tokens[0]).toEqual value: '@', scopes: ['source.sass', 'meta.at-rule.if.sass', 'keyword.control.if.sass', 'punctuation.definition.entity.sass']
      expect(tokens[1]).toEqual value: 'if', scopes: ['source.sass', 'meta.at-rule.if.sass', 'keyword.control.if.sass']
      expect(tokens[3]).toEqual value: '$', scopes: ['source.sass', 'meta.at-rule.if.sass', 'meta.variable-usage.sass', 'punctuation.definition.entity.css']
      expect(tokens[4]).toEqual value: 'var', scopes: ['source.sass', 'meta.at-rule.if.sass', 'meta.variable-usage.sass', 'variable.other.sass']
      expect(tokens[6]).toEqual value: '==', scopes: ['source.sass', 'meta.at-rule.if.sass', 'keyword.operator.comparison.sass']
      expect(tokens[8]).toEqual value: 'true', scopes: ['source.sass', 'meta.at-rule.if.sass', 'support.constant.property-value.css.sass']

    it 'tokenizes @else if', ->
      {tokens} = grammar.tokenizeLine '@else if $var == false'
      expect(tokens[0]).toEqual value: '@', scopes: ['source.sass', 'meta.at-rule.else.sass', 'keyword.control.else.sass', 'punctuation.definition.entity.sass']
      expect(tokens[1]).toEqual value: 'else if ', scopes: ['source.sass', 'meta.at-rule.else.sass', 'keyword.control.else.sass']
      expect(tokens[2]).toEqual value: '$', scopes: ['source.sass', 'meta.at-rule.else.sass', 'meta.variable-usage.sass', 'punctuation.definition.entity.css']
      expect(tokens[3]).toEqual value: 'var', scopes: ['source.sass', 'meta.at-rule.else.sass', 'meta.variable-usage.sass', 'variable.other.sass']
      expect(tokens[5]).toEqual value: '==', scopes: ['source.sass', 'meta.at-rule.else.sass', 'keyword.operator.comparison.sass']
      expect(tokens[7]).toEqual value: 'false', scopes: ['source.sass', 'meta.at-rule.else.sass', 'support.constant.property-value.css.sass']

    it 'tokenizes @while', ->
      {tokens} = grammar.tokenizeLine '@while 1'
      expect(tokens[0]).toEqual value: '@', scopes: ['source.sass', 'meta.at-rule.while.sass', 'keyword.control.while.sass', 'punctuation.definition.entity.sass']
      expect(tokens[1]).toEqual value: 'while', scopes: ['source.sass', 'meta.at-rule.while.sass', 'keyword.control.while.sass']
      expect(tokens[3]).toEqual value: '1', scopes: ['source.sass', 'meta.at-rule.while.sass', 'constant.numeric.css']

    it 'tokenizes @for', ->
      {tokens} = grammar.tokenizeLine '@for $i from 1 through 100'
      expect(tokens[0]).toEqual value: '@', scopes: ['source.sass', 'meta.at-rule.for.sass', 'keyword.control.for.sass', 'punctuation.definition.entity.sass']
      expect(tokens[1]).toEqual value: 'for', scopes: ['source.sass', 'meta.at-rule.for.sass', 'keyword.control.for.sass']
      expect(tokens[3]).toEqual value: '$', scopes: ['source.sass', 'meta.at-rule.for.sass', 'meta.variable-usage.sass', 'punctuation.definition.entity.css']
      expect(tokens[4]).toEqual value: 'i', scopes: ['source.sass', 'meta.at-rule.for.sass', 'meta.variable-usage.sass', 'variable.other.sass']
      expect(tokens[8]).toEqual value: '1', scopes: ['source.sass', 'meta.at-rule.for.sass', 'constant.numeric.css']
      expect(tokens[12]).toEqual value: '100', scopes: ['source.sass', 'meta.at-rule.for.sass', 'constant.numeric.css']
      # 'from' and 'thorugh' tested in operators

    it 'tokenizes @each', ->
      {tokens} = grammar.tokenizeLine '@each $item in $list'
      expect(tokens[0]).toEqual value: '@', scopes: ['source.sass', 'meta.at-rule.each.sass', 'keyword.control.each.sass', 'punctuation.definition.entity.sass']
      expect(tokens[1]).toEqual value: 'each', scopes: ['source.sass', 'meta.at-rule.each.sass', 'keyword.control.each.sass']
      expect(tokens[3]).toEqual value: '$', scopes: ['source.sass', 'meta.at-rule.each.sass', 'meta.variable-usage.sass', 'punctuation.definition.entity.css']
      expect(tokens[4]).toEqual value: 'item', scopes: ['source.sass', 'meta.at-rule.each.sass', 'meta.variable-usage.sass', 'variable.other.sass']
      expect(tokens[8]).toEqual value: '$', scopes: ['source.sass', 'meta.at-rule.each.sass', 'meta.variable-usage.sass', 'punctuation.definition.entity.css']
      expect(tokens[9]).toEqual value: 'list', scopes: ['source.sass', 'meta.at-rule.each.sass', 'meta.variable-usage.sass', 'variable.other.sass']
      # 'in' tested in operators

    it 'tokenizes @include or \'+\'', ->
      {tokens} = grammar.tokenizeLine '@include mixin-name'
      expect(tokens[0]).toEqual value: '@', scopes: ['source.sass', 'meta.function.include.sass', 'keyword.control.at-rule.include.sass', 'punctuation.definition.entity.sass']
      expect(tokens[1]).toEqual value: 'include', scopes: ['source.sass', 'meta.function.include.sass', 'keyword.control.at-rule.include.sass']

      {tokens} = grammar.tokenizeLine '+mixin-name'
      expect(tokens[0]).toEqual value: '+', scopes: ['source.sass', 'meta.function.include.sass', 'keyword.control.at-rule.include.sass']
      expect(tokens[1]).toEqual value: 'mixin-name', scopes: ['source.sass', 'meta.function.include.sass', 'variable.other.sass']

    it 'tokenizes @mixin or \'=\'', ->
      {tokens} = grammar.tokenizeLine '@mixin mixin-name($p)'
      expect(tokens[0]).toEqual value: '@', scopes: ['source.sass', 'meta.variable-declaration.sass.mixin', 'keyword.control.at-rule.mixin.sass', 'punctuation.definition.entity.sass']
      expect(tokens[1]).toEqual value: 'mixin', scopes: ['source.sass', 'meta.variable-declaration.sass.mixin', 'keyword.control.at-rule.mixin.sass']
      expect(tokens[3]).toEqual value: 'mixin-name', scopes: ['source.sass', 'meta.variable-declaration.sass.mixin', 'variable.other.sass']
      expect(tokens[5]).toEqual value: '$', scopes: ['source.sass', 'meta.variable-declaration.sass.mixin', 'meta.variable-usage.sass', 'punctuation.definition.entity.css']
      expect(tokens[6]).toEqual value: 'p', scopes: ['source.sass', 'meta.variable-declaration.sass.mixin', 'meta.variable-usage.sass', 'variable.other.sass']

      {tokens} = grammar.tokenizeLine '=mixin-name($p)'
      expect(tokens[0]).toEqual value: '\=', scopes: ['source.sass', 'meta.variable-declaration.sass.mixin', 'keyword.control.at-rule.keyframes.sass']
      expect(tokens[1]).toEqual value: 'mixin-name', scopes: ['source.sass', 'meta.variable-declaration.sass.mixin', 'variable.other.sass']
      expect(tokens[3]).toEqual value: '$', scopes: ['source.sass', 'meta.variable-declaration.sass.mixin', 'meta.variable-usage.sass', 'punctuation.definition.entity.css']
      expect(tokens[4]).toEqual value: 'p', scopes: ['source.sass', 'meta.variable-declaration.sass.mixin', 'meta.variable-usage.sass', 'variable.other.sass']

    it 'tokenizes @content', ->
      tokens = grammar.tokenizeLines '''
        @mixin mixin-name($p)
          @content
      '''
      expect(tokens[1][1]).toEqual value: '@', scopes: ['source.sass', 'meta.at-rule.content.sass', 'keyword.control.content.sass', 'punctuation.definition.entity.sass']
      expect(tokens[1][2]).toEqual value: 'content', scopes: ['source.sass', 'meta.at-rule.content.sass', 'keyword.control.content.sass']

    it 'tokenizes @warn, @debug and @error', ->
      {tokens} = grammar.tokenizeLine '@warn \'message\''
      expect(tokens[0]).toEqual value: '@', scopes: ['source.sass', 'meta.at-rule.warn.sass', 'keyword.control.warn.sass', 'punctuation.definition.entity.sass']
      expect(tokens[1]).toEqual value: 'warn', scopes: ['source.sass', 'meta.at-rule.warn.sass', 'keyword.control.warn.sass']
      expect(tokens[4]).toEqual value: 'message', scopes: ['source.sass', 'meta.at-rule.warn.sass', 'string.quoted.single.sass']

      {tokens} = grammar.tokenizeLine '@debug \'message\''
      expect(tokens[0]).toEqual value: '@', scopes: ['source.sass', 'meta.at-rule.warn.sass', 'keyword.control.warn.sass', 'punctuation.definition.entity.sass']
      expect(tokens[1]).toEqual value: 'debug', scopes: ['source.sass', 'meta.at-rule.warn.sass', 'keyword.control.warn.sass']
      expect(tokens[4]).toEqual value: 'message', scopes: ['source.sass', 'meta.at-rule.warn.sass', 'string.quoted.single.sass']

      {tokens} = grammar.tokenizeLine '@error \'message\''
      expect(tokens[0]).toEqual value: '@', scopes: ['source.sass', 'meta.at-rule.warn.sass', 'keyword.control.warn.sass', 'punctuation.definition.entity.sass']
      expect(tokens[1]).toEqual value: 'error', scopes: ['source.sass', 'meta.at-rule.warn.sass', 'keyword.control.warn.sass']
      expect(tokens[4]).toEqual value: 'message', scopes: ['source.sass', 'meta.at-rule.warn.sass', 'string.quoted.single.sass']

    it 'tokenizes @at-root', ->
      tokens = grammar.tokenizeLines '''
        .class
          @at-root
            #id
      '''
      expect(tokens[1][1]).toEqual value: '@', scopes: ['source.sass', 'meta.at-rule.at-root.sass', 'keyword.control.at-root.sass', 'punctuation.definition.entity.sass']
      expect(tokens[1][2]).toEqual value: 'at-root', scopes: ['source.sass', 'meta.at-rule.at-root.sass', 'keyword.control.at-root.sass']
      expect(tokens[2][1]).toEqual value: '#', scopes: [ 'source.sass', 'meta.selector.css', 'entity.other.attribute-name.id.css.sass', 'punctuation.definition.entity.sass']
      expect(tokens[2][2]).toEqual value: 'id', scopes: ['source.sass', 'meta.selector.css', 'entity.other.attribute-name.id.css.sass']

  describe 'operators', ->
    it 'correctly tokenizes comparison and logical operators', ->
      {tokens} = grammar.tokenizeLine '@if 1 == 1'
      expect(tokens[5]).toEqual value: '==', scopes: ['source.sass', 'meta.at-rule.if.sass', 'keyword.operator.comparison.sass']

      {tokens} = grammar.tokenizeLine '@if 1 != 1'
      expect(tokens[5]).toEqual value: '!=', scopes: ['source.sass', 'meta.at-rule.if.sass', 'keyword.operator.comparison.sass']

      {tokens} = grammar.tokenizeLine '@if 1 > 1'
      expect(tokens[5]).toEqual value: '>', scopes: ['source.sass', 'meta.at-rule.if.sass', 'keyword.operator.comparison.sass']

      {tokens} = grammar.tokenizeLine '@if 1 < 1'
      expect(tokens[5]).toEqual value: '<', scopes: ['source.sass', 'meta.at-rule.if.sass', 'keyword.operator.comparison.sass']

      {tokens} = grammar.tokenizeLine '@if 1 >= 1'
      expect(tokens[5]).toEqual value: '>=', scopes: ['source.sass', 'meta.at-rule.if.sass', 'keyword.operator.comparison.sass']

      {tokens} = grammar.tokenizeLine '@if 1 <= 1'
      expect(tokens[5]).toEqual value: '<=', scopes: ['source.sass', 'meta.at-rule.if.sass', 'keyword.operator.comparison.sass']

      {tokens} = grammar.tokenizeLine '@if 1 == 1 and 2 == 2'
      expect(tokens[9]).toEqual value: 'and', scopes: ['source.sass', 'meta.at-rule.if.sass', 'keyword.operator.logical.sass']

      {tokens} = grammar.tokenizeLine '@if 1 == 1 or 2 == 2'
      expect(tokens[9]).toEqual value: 'or', scopes: ['source.sass', 'meta.at-rule.if.sass', 'keyword.operator.logical.sass']

      {tokens} = grammar.tokenizeLine '@if not 1 == 1'
      expect(tokens[3]).toEqual value: 'not', scopes: ['source.sass', 'meta.at-rule.if.sass', 'keyword.operator.logical.sass']

    it 'correctly tokenizes control operators', ->
      {tokens} = grammar.tokenizeLine '@for $i from 1 through 2'
      expect(tokens[6]).toEqual value: 'from', scopes: ['source.sass', 'meta.at-rule.for.sass', 'keyword.operator.control.sass']
      expect(tokens[10]).toEqual value: 'through', scopes: ['source.sass', 'meta.at-rule.for.sass', 'keyword.operator.control.sass']

      {tokens} = grammar.tokenizeLine '@for $i from 1 to 2'
      expect(tokens[10]).toEqual value: 'to', scopes: ['source.sass', 'meta.at-rule.for.sass', 'keyword.operator.control.sass']

      {tokens} = grammar.tokenizeLine '@each $item in $list'
      expect(tokens[6]).toEqual value: 'in', scopes: ['source.sass', 'meta.at-rule.each.sass', 'keyword.operator.control.sass']
