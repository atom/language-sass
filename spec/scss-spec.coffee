describe 'SCSS grammar', ->
  grammar = null

  beforeEach ->
    waitsForPromise ->
      atom.packages.activatePackage('language-sass')

    runs ->
      grammar = atom.grammars.grammarForScopeName('source.css.scss')

  it 'parses the grammar', ->
    expect(grammar).toBeTruthy()
    expect(grammar.scopeName).toBe 'source.css.scss'

  describe 'numbers', ->
    it 'tokenizes them correctly', ->
      {tokens} = grammar.tokenizeLine '.something { color: 0 1 }'

      expect(tokens[8]).toEqual value: '0', scopes: ['source.css.scss', 'meta.property-list.scss', 'meta.property-value.scss', 'constant.numeric.scss']
      expect(tokens[10]).toEqual value: '1', scopes: ['source.css.scss', 'meta.property-list.scss', 'meta.property-value.scss', 'constant.numeric.scss']

      {tokens} = grammar.tokenizeLine '$q: (color1:$dark-orange);'

      expect(tokens[4]).toEqual value: 'color1', scopes: ['source.css.scss', 'meta.set.variable.scss', 'meta.set.variable.map.scss', 'support.type.map.key.scss']

    it 'tokenizes number operations', ->
      {tokens} = grammar.tokenizeLine '.something { top: +50%; }'

      expect(tokens[8]).toEqual value: '+', scopes: ['source.css.scss', 'meta.property-list.scss', 'meta.property-value.scss', 'keyword.operator.css']
      expect(tokens[9]).toEqual value: '50', scopes: ['source.css.scss', 'meta.property-list.scss', 'meta.property-value.scss', 'constant.numeric.scss']

      {tokens} = grammar.tokenizeLine '.something { top: 50% - 30%; }'

      expect(tokens[11]).toEqual value: '-', scopes: ['source.css.scss', 'meta.property-list.scss', 'meta.property-value.scss', 'keyword.operator.css']

  describe '@at-root', ->
    it 'tokenizes it correctly', ->
      {tokens} = grammar.tokenizeLine '@at-root (without: media) .btn { color: red; }'

      expect(tokens[0]).toEqual value: '@', scopes: ['source.css.scss', 'meta.at-rule.at-root.scss', 'keyword.control.at-rule.at-root.scss', 'punctuation.definition.keyword.scss']
      expect(tokens[1]).toEqual value: 'at-root', scopes: ['source.css.scss', 'meta.at-rule.at-root.scss', 'keyword.control.at-rule.at-root.scss']

  describe '@page', ->
    it 'tokenizes it correctly', ->
      tokens = grammar.tokenizeLines """
        @page {
          text-align: center;
        }
      """

      expect(tokens[0][0]).toEqual value: '@', scopes: ['source.css.scss', 'meta.at-rule.page.scss', 'keyword.control.at-rule.page.scss', 'punctuation.definition.keyword.scss']
      expect(tokens[0][1]).toEqual value: 'page', scopes: ['source.css.scss', 'meta.at-rule.page.scss', 'keyword.control.at-rule.page.scss']
      expect(tokens[1][0]).toEqual value: '  ', scopes: ['source.css.scss', 'meta.property-list.scss']
      expect(tokens[1][1]).toEqual value: 'text-align', scopes: ['source.css.scss', 'meta.property-list.scss', 'meta.property-name.scss', 'support.type.property-name.scss']
      expect(tokens[1][2]).toEqual value: ':', scopes: ['source.css.scss', 'meta.property-list.scss', 'punctuation.separator.key-value.scss']
      expect(tokens[1][3]).toEqual value: ' ', scopes: ['source.css.scss', 'meta.property-list.scss']
      expect(tokens[1][4]).toEqual value: 'center', scopes: ['source.css.scss', 'meta.property-list.scss', 'meta.property-value.scss', 'support.constant.property-value.scss']

      tokens = grammar.tokenizeLines """
        @page :left {
          text-align: center;
        }
      """

      expect(tokens[0][0]).toEqual value: '@', scopes: ['source.css.scss', 'meta.at-rule.page.scss', 'keyword.control.at-rule.page.scss', 'punctuation.definition.keyword.scss']
      expect(tokens[0][1]).toEqual value: 'page', scopes: ['source.css.scss', 'meta.at-rule.page.scss', 'keyword.control.at-rule.page.scss']
      expect(tokens[0][2]).toEqual value: ' ', scopes: ['source.css.scss', 'meta.at-rule.page.scss']
      expect(tokens[0][3]).toEqual value: ':left', scopes: ['source.css.scss', 'meta.at-rule.page.scss', 'entity.name.function.scss']
      expect(tokens[1][0]).toEqual value: '  ', scopes: ['source.css.scss', 'meta.property-list.scss']
      expect(tokens[1][1]).toEqual value: 'text-align', scopes: ['source.css.scss', 'meta.property-list.scss', 'meta.property-name.scss', 'support.type.property-name.scss']
      expect(tokens[1][2]).toEqual value: ':', scopes: ['source.css.scss', 'meta.property-list.scss', 'punctuation.separator.key-value.scss']
      expect(tokens[1][3]).toEqual value: ' ', scopes: ['source.css.scss', 'meta.property-list.scss']
      expect(tokens[1][4]).toEqual value: 'center', scopes: ['source.css.scss', 'meta.property-list.scss', 'meta.property-value.scss', 'support.constant.property-value.scss']

      tokens = grammar.tokenizeLines """
        @page:left {
          text-align: center;
        }
      """

      expect(tokens[0][0]).toEqual value: '@', scopes: ['source.css.scss', 'meta.at-rule.page.scss', 'keyword.control.at-rule.page.scss', 'punctuation.definition.keyword.scss']
      expect(tokens[0][1]).toEqual value: 'page', scopes: ['source.css.scss', 'meta.at-rule.page.scss', 'keyword.control.at-rule.page.scss']
      expect(tokens[0][2]).toEqual value: ':left', scopes: ['source.css.scss', 'meta.at-rule.page.scss', 'entity.name.function.scss']
      expect(tokens[1][0]).toEqual value: '  ', scopes: ['source.css.scss', 'meta.property-list.scss']
      expect(tokens[1][1]).toEqual value: 'text-align', scopes: ['source.css.scss', 'meta.property-list.scss', 'meta.property-name.scss', 'support.type.property-name.scss']
      expect(tokens[1][2]).toEqual value: ':', scopes: ['source.css.scss', 'meta.property-list.scss', 'punctuation.separator.key-value.scss']
      expect(tokens[1][3]).toEqual value: ' ', scopes: ['source.css.scss', 'meta.property-list.scss']
      expect(tokens[1][4]).toEqual value: 'center', scopes: ['source.css.scss', 'meta.property-list.scss', 'meta.property-value.scss', 'support.constant.property-value.scss']

  describe 'property-list', ->
    it 'tokenizes the property-name and property-value', ->
      {tokens} = grammar.tokenizeLine 'very-custom { color: inherit; }'

      expect(tokens[4]).toEqual value: 'color', scopes: ['source.css.scss', 'meta.property-list.scss', 'meta.property-name.scss', 'support.type.property-name.scss']
      expect(tokens[7]).toEqual value: 'inherit', scopes: ['source.css.scss', 'meta.property-list.scss', 'meta.property-value.scss', 'support.constant.property-value.scss']
      expect(tokens[8]).toEqual value: ';', scopes: ['source.css.scss', 'meta.property-list.scss', 'punctuation.terminator.rule.scss']
      expect(tokens[10]).toEqual value: '}', scopes: ['source.css.scss', 'meta.property-list.scss', 'punctuation.section.property-list.end.bracket.curly.scss']

    it 'tokenizes nested property-lists', ->
      {tokens} = grammar.tokenizeLine 'very-custom { very-very-custom { color: inherit; } margin: top; }'

      expect(tokens[2]).toEqual value: '{', scopes: ['source.css.scss', 'meta.property-list.scss', 'punctuation.section.property-list.begin.bracket.curly.scss']
      expect(tokens[4]).toEqual value: 'very-very-custom', scopes: ['source.css.scss', 'meta.property-list.scss', 'entity.name.tag.custom.scss']
      expect(tokens[6]).toEqual value: '{', scopes: ['source.css.scss', 'meta.property-list.scss', 'meta.property-list.scss', 'punctuation.section.property-list.begin.bracket.curly.scss']
      expect(tokens[8]).toEqual value: 'color', scopes: ['source.css.scss', 'meta.property-list.scss', 'meta.property-list.scss', 'meta.property-name.scss', 'support.type.property-name.scss']
      expect(tokens[11]).toEqual value: 'inherit', scopes: ['source.css.scss', 'meta.property-list.scss', 'meta.property-list.scss', 'meta.property-value.scss', 'support.constant.property-value.scss']
      expect(tokens[12]).toEqual value: ';', scopes: ['source.css.scss', 'meta.property-list.scss', 'meta.property-list.scss', 'punctuation.terminator.rule.scss']
      expect(tokens[14]).toEqual value: '}', scopes: ['source.css.scss', 'meta.property-list.scss', 'meta.property-list.scss', 'punctuation.section.property-list.end.bracket.curly.scss']
      expect(tokens[16]).toEqual value: 'margin', scopes: ['source.css.scss', 'meta.property-list.scss', 'meta.property-name.scss', 'support.type.property-name.scss']
      expect(tokens[19]).toEqual value: 'top', scopes: ['source.css.scss', 'meta.property-list.scss', 'meta.property-value.scss', 'support.constant.property-value.scss']
      expect(tokens[22]).toEqual value: '}', scopes: ['source.css.scss', 'meta.property-list.scss', 'punctuation.section.property-list.end.bracket.curly.scss']

    it 'tokenizes an incomplete inline property-list', ->
      {tokens} = grammar.tokenizeLine 'very-custom { color: inherit}'

      expect(tokens[4]).toEqual value: 'color', scopes: ['source.css.scss', 'meta.property-list.scss', 'meta.property-name.scss', 'support.type.property-name.scss']
      expect(tokens[7]).toEqual value: 'inherit', scopes: ['source.css.scss', 'meta.property-list.scss', 'meta.property-value.scss', 'support.constant.property-value.scss']
      expect(tokens[8]).toEqual value: '}', scopes: ['source.css.scss', 'meta.property-list.scss', 'punctuation.section.property-list.end.bracket.curly.scss']

    it 'tokenizes multiple lines of incomplete property-list', ->
      tokens = grammar.tokenizeLines """
        very-custom { color: inherit }
        another-one { display: none; }
      """

      expect(tokens[0][0]).toEqual value: 'very-custom', scopes: ['source.css.scss', 'entity.name.tag.custom.scss']
      expect(tokens[0][4]).toEqual value: 'color', scopes: ['source.css.scss', 'meta.property-list.scss', 'meta.property-name.scss', 'support.type.property-name.scss']
      expect(tokens[0][7]).toEqual value: 'inherit', scopes: ['source.css.scss', 'meta.property-list.scss', 'meta.property-value.scss', 'support.constant.property-value.scss']
      expect(tokens[0][9]).toEqual value: '}', scopes: ['source.css.scss', 'meta.property-list.scss', 'punctuation.section.property-list.end.bracket.curly.scss']
      expect(tokens[1][0]).toEqual value: 'another-one', scopes: ['source.css.scss', 'entity.name.tag.custom.scss']
      expect(tokens[1][10]).toEqual value: '}', scopes: ['source.css.scss', 'meta.property-list.scss', 'punctuation.section.property-list.end.bracket.curly.scss']

  describe 'property names with a prefix that matches an element name', ->
    it 'does not confuse them with properties', ->
      tokens = grammar.tokenizeLines """
        text {
          text-align: center;
        }
      """

      expect(tokens[0][0]).toEqual value: 'text', scopes: ['source.css.scss', 'entity.name.tag.scss']
      expect(tokens[1][0]).toEqual value: '  ', scopes: ['source.css.scss', 'meta.property-list.scss']
      expect(tokens[1][1]).toEqual value: 'text-align', scopes: ['source.css.scss', 'meta.property-list.scss', 'meta.property-name.scss', 'support.type.property-name.scss']
      expect(tokens[1][2]).toEqual value: ':', scopes: ['source.css.scss', 'meta.property-list.scss', 'punctuation.separator.key-value.scss']
      expect(tokens[1][3]).toEqual value: ' ', scopes: ['source.css.scss', 'meta.property-list.scss']
      expect(tokens[1][4]).toEqual value: 'center', scopes: ['source.css.scss', 'meta.property-list.scss', 'meta.property-value.scss', 'support.constant.property-value.scss']

      tokens = grammar.tokenizeLines """
        table {
          table-layout: fixed;
        }
      """

      expect(tokens[0][0]).toEqual value: 'table', scopes: ['source.css.scss', 'entity.name.tag.scss']
      expect(tokens[1][0]).toEqual value: '  ', scopes: ['source.css.scss', 'meta.property-list.scss']
      expect(tokens[1][1]).toEqual value: 'table-layout', scopes: ['source.css.scss', 'meta.property-list.scss', 'meta.property-name.scss', 'support.type.property-name.scss']
      expect(tokens[1][2]).toEqual value: ':', scopes: ['source.css.scss', 'meta.property-list.scss', 'punctuation.separator.key-value.scss']
      expect(tokens[1][3]).toEqual value: ' ', scopes: ['source.css.scss', 'meta.property-list.scss']
      expect(tokens[1][4]).toEqual value: 'fixed', scopes: ['source.css.scss', 'meta.property-list.scss', 'meta.property-value.scss', 'support.constant.property-value.scss']

  describe 'vendor properties', ->
    it 'tokenizes the browser prefix', ->
      {tokens} = grammar.tokenizeLine 'body { -webkit-box-shadow: none; }'

      expect(tokens[0]).toEqual value: 'body', scopes: ['source.css.scss', 'entity.name.tag.scss']
      expect(tokens[4]).toEqual value: '-webkit-box-shadow', scopes: ['source.css.scss', 'meta.property-list.scss', 'meta.property-name.scss', 'support.type.property-name.scss']

  describe 'custom elements', ->
    it 'tokenizes them as tags', ->
      {tokens} = grammar.tokenizeLine 'very-custom { color: red; }'

      expect(tokens[0]).toEqual value: 'very-custom', scopes: ['source.css.scss', 'entity.name.tag.custom.scss']

      {tokens} = grammar.tokenizeLine 'very-very-custom { color: red; }'

      expect(tokens[0]).toEqual value: 'very-very-custom', scopes: ['source.css.scss', 'entity.name.tag.custom.scss']

    it 'tokenizes them with pseudo selectors', ->
      {tokens} = grammar.tokenizeLine 'very-custom:hover { color: red; }'

      expect(tokens[0]).toEqual value: 'very-custom', scopes: ['source.css.scss', 'entity.name.tag.custom.scss']
      expect(tokens[1]).toEqual value: ':', scopes: ['source.css.scss', 'punctuation.definition.entity.css']
      expect(tokens[2]).toEqual value: 'hover', scopes: ['source.css.scss', 'entity.other.attribute-name.pseudo-class.css']

    it 'tokenizes them with class selectors', ->
      {tokens} = grammar.tokenizeLine 'very-custom.class { color: red; }'

      expect(tokens[0]).toEqual value: 'very-custom', scopes: ['source.css.scss', 'entity.name.tag.custom.scss']
      expect(tokens[1]).toEqual value: '.', scopes: ['source.css.scss', 'entity.other.attribute-name.class.css', 'punctuation.definition.entity.css']
      expect(tokens[2]).toEqual value: 'class', scopes: ['source.css.scss', 'entity.other.attribute-name.class.css']

    it 'does not confuse them with properties', ->
      tokens = grammar.tokenizeLines """
        body {
          border-width: 2;
          font-size : 2;
          background-image  : none;
        }
      """

      expect(tokens[1][0]).toEqual value: '  ', scopes: ['source.css.scss', 'meta.property-list.scss']
      expect(tokens[1][1]).toEqual value: 'border-width', scopes: ['source.css.scss', 'meta.property-list.scss', 'meta.property-name.scss', 'support.type.property-name.scss']
      expect(tokens[1][2]).toEqual value: ':', scopes: ['source.css.scss', 'meta.property-list.scss', 'punctuation.separator.key-value.scss']
      expect(tokens[1][3]).toEqual value: ' ', scopes: ['source.css.scss', 'meta.property-list.scss']
      expect(tokens[1][4]).toEqual value: '2', scopes: ['source.css.scss', 'meta.property-list.scss', 'meta.property-value.scss', 'constant.numeric.scss']
      expect(tokens[2][0]).toEqual value: '  ', scopes: ['source.css.scss', 'meta.property-list.scss']
      expect(tokens[2][1]).toEqual value: 'font-size', scopes: ['source.css.scss', 'meta.property-list.scss', 'meta.property-name.scss', 'support.type.property-name.scss']
      expect(tokens[2][2]).toEqual value: ' ', scopes: ['source.css.scss', 'meta.property-list.scss']
      expect(tokens[2][3]).toEqual value: ':', scopes: ['source.css.scss', 'meta.property-list.scss', 'punctuation.separator.key-value.scss']
      expect(tokens[2][4]).toEqual value: ' ', scopes: ['source.css.scss', 'meta.property-list.scss']
      expect(tokens[2][5]).toEqual value: '2', scopes: ['source.css.scss', 'meta.property-list.scss', 'meta.property-value.scss', 'constant.numeric.scss']
      expect(tokens[3][0]).toEqual value: '  ', scopes: ['source.css.scss', 'meta.property-list.scss']
      expect(tokens[3][1]).toEqual value: 'background-image', scopes: ['source.css.scss', 'meta.property-list.scss', 'meta.property-name.scss', 'support.type.property-name.scss']
      expect(tokens[3][2]).toEqual value: '  ', scopes: ['source.css.scss', 'meta.property-list.scss']
      expect(tokens[3][3]).toEqual value: ':', scopes: ['source.css.scss', 'meta.property-list.scss', 'punctuation.separator.key-value.scss']
      expect(tokens[3][4]).toEqual value: ' ', scopes: ['source.css.scss', 'meta.property-list.scss']
      expect(tokens[3][5]).toEqual value: 'none', scopes: ['source.css.scss', 'meta.property-list.scss', 'meta.property-value.scss', 'support.constant.property-value.scss']

  describe 'pseudo classes', ->
    it 'tokenizes them', ->
      {tokens} = grammar.tokenizeLine 'a:hover {}'

      expect(tokens[1]).toEqual value: ':', scopes: ['source.css.scss', 'punctuation.definition.entity.css']
      expect(tokens[2]).toEqual value: 'hover', scopes: ['source.css.scss', 'entity.other.attribute-name.pseudo-class.css']

    it 'tokenizes nth-* pseudo classes', ->
      {tokens} = grammar.tokenizeLine 'a:nth-child(n)'

      expect(tokens[2]).toEqual value: 'nth-child', scopes: ['source.css.scss', 'entity.other.attribute-name.pseudo-class.css']
      expect(tokens[3]).toEqual value: '(', scopes: ['source.css.scss', 'punctuation.definition.pseudo-class.begin.bracket.round.css']
      expect(tokens[4]).toEqual value: 'n', scopes: ['source.css.scss', 'constant.other.scss']
      expect(tokens[5]).toEqual value: ')', scopes: ['source.css.scss', 'punctuation.definition.pseudo-class.end.bracket.round.css']

      {tokens} = grammar.tokenizeLine 'a:nth-child(3n)'

      expect(tokens[2]).toEqual value: 'nth-child', scopes: ['source.css.scss', 'entity.other.attribute-name.pseudo-class.css']
      expect(tokens[3]).toEqual value: '(', scopes: ['source.css.scss', 'punctuation.definition.pseudo-class.begin.bracket.round.css']
      expect(tokens[4]).toEqual value: '3', scopes: ['source.css.scss', 'constant.numeric.scss']
      expect(tokens[5]).toEqual value: 'n', scopes: ['source.css.scss', 'constant.other.scss']
      expect(tokens[6]).toEqual value: ')', scopes: ['source.css.scss', 'punctuation.definition.pseudo-class.end.bracket.round.css']

      {tokens} = grammar.tokenizeLine 'a:nth-child(2)'

      expect(tokens[2]).toEqual value: 'nth-child', scopes: ['source.css.scss', 'entity.other.attribute-name.pseudo-class.css']
      expect(tokens[3]).toEqual value: '(', scopes: ['source.css.scss', 'punctuation.definition.pseudo-class.begin.bracket.round.css']
      expect(tokens[4]).toEqual value: '2', scopes: ['source.css.scss', 'constant.numeric.scss']
      expect(tokens[5]).toEqual value: ')', scopes: ['source.css.scss', 'punctuation.definition.pseudo-class.end.bracket.round.css']

      {tokens} = grammar.tokenizeLine 'a:nth-child(n + 2)'

      expect(tokens[2]).toEqual value: 'nth-child', scopes: ['source.css.scss', 'entity.other.attribute-name.pseudo-class.css']
      expect(tokens[3]).toEqual value: '(', scopes: ['source.css.scss', 'punctuation.definition.pseudo-class.begin.bracket.round.css']
      expect(tokens[4]).toEqual value: 'n', scopes: ['source.css.scss', 'constant.other.scss']
      expect(tokens[6]).toEqual value: '2', scopes: ['source.css.scss', 'constant.numeric.scss']
      expect(tokens[7]).toEqual value: ')', scopes: ['source.css.scss', 'punctuation.definition.pseudo-class.end.bracket.round.css']

      {tokens} = grammar.tokenizeLine 'a:nth-child(3n + 2)'

      expect(tokens[2]).toEqual value: 'nth-child', scopes: ['source.css.scss', 'entity.other.attribute-name.pseudo-class.css']
      expect(tokens[3]).toEqual value: '(', scopes: ['source.css.scss', 'punctuation.definition.pseudo-class.begin.bracket.round.css']
      expect(tokens[4]).toEqual value: '3', scopes: ['source.css.scss', 'constant.numeric.scss']
      expect(tokens[5]).toEqual value: 'n', scopes: ['source.css.scss', 'constant.other.scss']
      expect(tokens[7]).toEqual value: '2', scopes: ['source.css.scss', 'constant.numeric.scss']
      expect(tokens[8]).toEqual value: ')', scopes: ['source.css.scss', 'punctuation.definition.pseudo-class.end.bracket.round.css']

      {tokens} = grammar.tokenizeLine 'a:nth-child(hi)'

      expect(tokens[2]).toEqual value: 'nth-child', scopes: ['source.css.scss', 'entity.other.attribute-name.pseudo-class.css']
      expect(tokens[3]).toEqual value: '(', scopes: ['source.css.scss', 'punctuation.definition.pseudo-class.begin.bracket.round.css']
      expect(tokens[4]).toEqual value: 'hi', scopes: ['source.css.scss', 'invalid.illegal.scss']
      expect(tokens[5]).toEqual value: ')', scopes: ['source.css.scss', 'punctuation.definition.pseudo-class.end.bracket.round.css']

  describe "attribute selectors", ->
    it "parses them correctly", ->
      {tokens} = grammar.tokenizeLine '[something="1"]'

      expect(tokens[0]).toEqual value: '[', scopes: ['source.css.scss', 'meta.attribute-selector.scss', 'punctuation.definition.attribute-selector.begin.bracket.square.scss']
      expect(tokens[1]).toEqual value: 'something', scopes: ['source.css.scss', 'meta.attribute-selector.scss', 'entity.other.attribute-name.attribute.scss']
      expect(tokens[2]).toEqual value: '=', scopes: ['source.css.scss', 'meta.attribute-selector.scss', 'punctuation.separator.operator.scss']
      expect(tokens[3]).toEqual value: '"', scopes: ['source.css.scss', 'meta.attribute-selector.scss', 'string.quoted.double.attribute-value.scss', 'punctuation.definition.string.begin.scss']
      expect(tokens[5]).toEqual value: '"', scopes: ['source.css.scss', 'meta.attribute-selector.scss', 'string.quoted.double.attribute-value.scss', 'punctuation.definition.string.end.scss']
      expect(tokens[6]).toEqual value: ']', scopes: ['source.css.scss', 'meta.attribute-selector.scss', 'punctuation.definition.attribute-selector.end.bracket.square.scss']

  describe "keyframes", ->
    it "parses the from and to properties", ->
      tokens = grammar.tokenizeLines """
        @keyframes anim {
        from { opacity: 0; }
        to { opacity: 1; }
        }
      """

      expect(tokens[0][0]).toEqual value: '@', scopes: ['source.css.scss', 'meta.at-rule.keyframes.scss', 'keyword.control.at-rule.keyframes.scss', 'punctuation.definition.keyword.scss']
      expect(tokens[0][1]).toEqual value: 'keyframes', scopes: ['source.css.scss', 'meta.at-rule.keyframes.scss', 'keyword.control.at-rule.keyframes.scss']
      expect(tokens[0][2]).toEqual value: ' ', scopes: ['source.css.scss', 'meta.at-rule.keyframes.scss']
      expect(tokens[0][3]).toEqual value: 'anim', scopes: ['source.css.scss', 'meta.at-rule.keyframes.scss', 'entity.name.function.scss']
      expect(tokens[1][0]).toEqual value: 'from', scopes: ['source.css.scss', 'meta.at-rule.keyframes.scss', 'meta.keyframes.scss', 'entity.other.attribute-name.scss']
      expect(tokens[1][4]).toEqual value: 'opacity', scopes: ['source.css.scss', 'meta.at-rule.keyframes.scss', 'meta.keyframes.scss', 'meta.property-list.scss', 'meta.property-name.scss', 'support.type.property-name.scss']
      expect(tokens[1][7]).toEqual value: '0', scopes: ['source.css.scss', 'meta.at-rule.keyframes.scss', 'meta.keyframes.scss', 'meta.property-list.scss', 'meta.property-value.scss', 'constant.numeric.scss']
      expect(tokens[2][0]).toEqual value: 'to', scopes: ['source.css.scss', 'meta.at-rule.keyframes.scss', 'meta.keyframes.scss', 'entity.other.attribute-name.scss']
      expect(tokens[2][4]).toEqual value: 'opacity', scopes: ['source.css.scss', 'meta.at-rule.keyframes.scss', 'meta.keyframes.scss', 'meta.property-list.scss', 'meta.property-name.scss', 'support.type.property-name.scss']
      expect(tokens[2][7]).toEqual value: '1', scopes: ['source.css.scss', 'meta.at-rule.keyframes.scss', 'meta.keyframes.scss', 'meta.property-list.scss', 'meta.property-value.scss', 'constant.numeric.scss']

  describe 'media queries', ->
    it 'parses media types and features', ->
      {tokens} = grammar.tokenizeLine '@media (orientation: landscape) and only screen and (min-width: 700px) {}'

      expect(tokens[0]).toEqual value: '@', scopes: ['source.css.scss', 'meta.at-rule.media.scss', 'keyword.control.at-rule.media.scss', 'punctuation.definition.keyword.scss']
      expect(tokens[1]).toEqual value: 'media', scopes: ['source.css.scss', 'meta.at-rule.media.scss', 'keyword.control.at-rule.media.scss']
      expect(tokens[4]).toEqual value: 'orientation', scopes: ['source.css.scss', 'meta.at-rule.media.scss', 'support.type.property-name.media.css']
      expect(tokens[6]).toEqual value: 'landscape', scopes: ['source.css.scss', 'meta.at-rule.media.scss', 'support.constant.property-value.scss']
      expect(tokens[8]).toEqual value: 'and', scopes: ['source.css.scss', 'meta.at-rule.media.scss', 'keyword.control.operator']
      expect(tokens[10]).toEqual value: 'only', scopes: ['source.css.scss', 'meta.at-rule.media.scss', 'keyword.control.operator']
      expect(tokens[12]).toEqual value: 'screen', scopes: ['source.css.scss', 'meta.at-rule.media.scss', 'support.constant.media.css']
      expect(tokens[14]).toEqual value: 'and', scopes: ['source.css.scss', 'meta.at-rule.media.scss', 'keyword.control.operator']
      expect(tokens[16]).toEqual value: 'min-width', scopes: ['source.css.scss', 'meta.at-rule.media.scss', 'support.type.property-name.media.css']
      expect(tokens[18]).toEqual value: '700', scopes: ['source.css.scss', 'meta.at-rule.media.scss', 'constant.numeric.scss']
      expect(tokens[19]).toEqual value: 'px', scopes: ['source.css.scss', 'meta.at-rule.media.scss', 'keyword.other.unit.scss']

  describe 'functions', ->
    it 'parses them', ->
      {tokens} = grammar.tokenizeLine '.a { hello: something($wow, 3) }'

      expect(tokens[8]).toEqual value: 'something', scopes: ['source.css.scss', 'meta.property-list.scss', 'meta.property-value.scss', 'support.function.misc.scss']
      expect(tokens[9]).toEqual value: '(', scopes: ['source.css.scss', 'meta.property-list.scss', 'meta.property-value.scss', 'punctuation.section.function.scss']
      expect(tokens[10]).toEqual value: '$wow', scopes: ['source.css.scss', 'meta.property-list.scss', 'meta.property-value.scss', 'variable.scss', 'variable.scss']
      expect(tokens[11]).toEqual value: ',', scopes: ['source.css.scss', 'meta.property-list.scss', 'meta.property-value.scss', 'punctuation.scss']
      expect(tokens[13]).toEqual value: '3', scopes: ['source.css.scss', 'meta.property-list.scss', 'meta.property-value.scss', 'constant.numeric.scss']
      expect(tokens[14]).toEqual value: ')', scopes: ['source.css.scss', 'meta.property-list.scss', 'meta.property-value.scss', 'punctuation.section.function.scss']

    it 'tokenizes functions with parentheses in them', ->
      {tokens} = grammar.tokenizeLine '.a { hello: something((a: $b)) }'

      expect(tokens[8]).toEqual value: 'something', scopes: ['source.css.scss', 'meta.property-list.scss', 'meta.property-value.scss', 'support.function.misc.scss']
      expect(tokens[9]).toEqual value: '(', scopes: ['source.css.scss', 'meta.property-list.scss', 'meta.property-value.scss', 'punctuation.section.function.scss']
      expect(tokens[10]).toEqual value: '(', scopes: ['source.css.scss', 'meta.property-list.scss', 'meta.property-value.scss', 'punctuation.definition.begin.bracket.round.scss']
      expect(tokens[11]).toEqual value: 'a', scopes: ['source.css.scss', 'meta.property-list.scss', 'meta.property-value.scss']
      expect(tokens[12]).toEqual value: ':', scopes: ['source.css.scss', 'meta.property-list.scss', 'meta.property-value.scss', 'punctuation.definition']
      expect(tokens[14]).toEqual value: '$b', scopes: ['source.css.scss', 'meta.property-list.scss', 'meta.property-value.scss', 'variable.scss', 'variable.scss']
      expect(tokens[15]).toEqual value: ')', scopes: ['source.css.scss', 'meta.property-list.scss', 'meta.property-value.scss', 'punctuation.definition.end.bracket.round.scss']
      expect(tokens[16]).toEqual value: ')', scopes: ['source.css.scss', 'meta.property-list.scss', 'meta.property-value.scss', 'punctuation.section.function.scss']

  describe 'variable setting', ->
    it 'parses all tokens', ->
      {tokens} = grammar.tokenizeLine '$font-size: $normal-font-size;'

      expect(tokens[0]).toEqual value: '$font-size', scopes: ['source.css.scss', 'meta.set.variable.scss', 'variable.scss']
      expect(tokens[1]).toEqual value: ':', scopes: ['source.css.scss', 'meta.set.variable.scss', 'punctuation.separator.key-value.scss']
      expect(tokens[2]).toEqual value: ' ', scopes: ['source.css.scss', 'meta.set.variable.scss']
      expect(tokens[3]).toEqual value: '$normal-font-size', scopes: ['source.css.scss', 'meta.set.variable.scss', 'variable.scss', 'variable.scss']

    it 'tokenizes maps', ->
      {tokens} = grammar.tokenizeLine '$map: (medium: value, header-height: 10px);'

      expect(tokens[0]).toEqual value: '$map', scopes: ['source.css.scss', 'meta.set.variable.scss', 'variable.scss']
      expect(tokens[1]).toEqual value: ':', scopes: ['source.css.scss', 'meta.set.variable.scss', 'punctuation.separator.key-value.scss']
      expect(tokens[2]).toEqual value: ' ', scopes: ['source.css.scss', 'meta.set.variable.scss']
      expect(tokens[3]).toEqual value: '(', scopes: ['source.css.scss', 'meta.set.variable.scss', 'meta.set.variable.map.scss', 'punctuation.definition.map.begin.bracket.round.scss']
      expect(tokens[4]).toEqual value: 'medium', scopes: ['source.css.scss', 'meta.set.variable.scss', 'meta.set.variable.map.scss', 'support.type.map.key.scss']
      expect(tokens[5]).toEqual value: ':', scopes: ['source.css.scss', 'meta.set.variable.scss', 'meta.set.variable.map.scss', 'punctuation.separator.key-value.scss']
      expect(tokens[6]).toEqual value: ' value', scopes: ['source.css.scss', 'meta.set.variable.scss', 'meta.set.variable.map.scss']
      expect(tokens[7]).toEqual value: ',', scopes: ['source.css.scss', 'meta.set.variable.scss', 'meta.set.variable.map.scss', 'punctuation.separator.delimiter.scss']
      expect(tokens[8]).toEqual value: ' ', scopes: ['source.css.scss', 'meta.set.variable.scss', 'meta.set.variable.map.scss']
      expect(tokens[9]).toEqual value: 'header-height', scopes: ['source.css.scss', 'meta.set.variable.scss', 'meta.set.variable.map.scss', 'support.type.map.key.scss']
      expect(tokens[10]).toEqual value: ':', scopes: ['source.css.scss', 'meta.set.variable.scss', 'meta.set.variable.map.scss', 'punctuation.separator.key-value.scss']
      expect(tokens[11]).toEqual value: ' ', scopes: ['source.css.scss', 'meta.set.variable.scss', 'meta.set.variable.map.scss']
      expect(tokens[12]).toEqual value: '10', scopes: ['source.css.scss', 'meta.set.variable.scss', 'meta.set.variable.map.scss', 'constant.numeric.scss']
      expect(tokens[14]).toEqual value: ')', scopes: ['source.css.scss', 'meta.set.variable.scss', 'meta.set.variable.map.scss', 'punctuation.definition.map.end.bracket.round.scss']

    it 'tokenizes comments', ->
      {tokens} = grammar.tokenizeLine '$font-size: // comment'

      expect(tokens[3]).toEqual value: '//', scopes: ['source.css.scss', 'meta.set.variable.scss', 'comment.line.scss', 'punctuation.definition.comment.scss']

      {tokens} = grammar.tokenizeLine '$font-size: /* comment */'

      expect(tokens[3]).toEqual value: '/*', scopes: ['source.css.scss', 'meta.set.variable.scss', 'comment.block.scss', 'punctuation.definition.comment.scss']

    it 'tokenizes comments in maps', ->
      {tokens} = grammar.tokenizeLine '$map: (/* comment */ key: // comment)'

      expect(tokens[4]).toEqual value: '/*', scopes: ['source.css.scss', 'meta.set.variable.scss', 'meta.set.variable.map.scss', 'comment.block.scss', 'punctuation.definition.comment.scss']
      expect(tokens[11]).toEqual value: '//', scopes: ['source.css.scss', 'meta.set.variable.scss', 'meta.set.variable.map.scss', 'comment.line.scss', 'punctuation.definition.comment.scss']

  describe 'interpolation', ->
    it 'is tokenized within single quotes', ->
      {tokens} = grammar.tokenizeLine "body { font-family: '#\{$family}'; }" # escaping CoffeeScript's interpolation

      expect(tokens[8]).toEqual value: '#{', scopes: ['source.css.scss', 'meta.property-list.scss', 'meta.property-value.scss', 'string.quoted.single.scss', 'variable.interpolation.scss', 'punctuation.definition.interpolation.begin.bracket.curly.scss']
      expect(tokens[9]).toEqual value: '$family', scopes: ['source.css.scss', 'meta.property-list.scss', 'meta.property-value.scss', 'string.quoted.single.scss', 'variable.interpolation.scss', 'variable.scss', 'variable.scss']
      expect(tokens[10]).toEqual value: '}', scopes: ['source.css.scss', 'meta.property-list.scss', 'meta.property-value.scss', 'string.quoted.single.scss', 'variable.interpolation.scss', 'punctuation.definition.interpolation.end.bracket.curly.scss']

    it 'is tokenized within double quotes', ->
      {tokens} = grammar.tokenizeLine 'body { font-family: "#\{$family}"; }'

      expect(tokens[8]).toEqual value: '#{', scopes: ['source.css.scss', 'meta.property-list.scss', 'meta.property-value.scss', 'string.quoted.double.scss', 'variable.interpolation.scss', 'punctuation.definition.interpolation.begin.bracket.curly.scss']
      expect(tokens[9]).toEqual value: '$family', scopes: ['source.css.scss', 'meta.property-list.scss', 'meta.property-value.scss', 'string.quoted.double.scss', 'variable.interpolation.scss', 'variable.scss', 'variable.scss']
      expect(tokens[10]).toEqual value: '}', scopes: ['source.css.scss', 'meta.property-list.scss', 'meta.property-value.scss', 'string.quoted.double.scss', 'variable.interpolation.scss', 'punctuation.definition.interpolation.end.bracket.curly.scss']

    it 'is tokenized without quotes', ->
      {tokens} = grammar.tokenizeLine 'body { font-family: #\{$family}; }'

      expect(tokens[7]).toEqual value: '#{', scopes: ['source.css.scss', 'meta.property-list.scss', 'meta.property-value.scss', 'variable.interpolation.scss', 'punctuation.definition.interpolation.begin.bracket.curly.scss']
      expect(tokens[8]).toEqual value: '$family', scopes: ['source.css.scss', 'meta.property-list.scss', 'meta.property-value.scss', 'variable.interpolation.scss', 'variable.scss', 'variable.scss']
      expect(tokens[9]).toEqual value: '}', scopes: ['source.css.scss', 'meta.property-list.scss', 'meta.property-value.scss', 'variable.interpolation.scss', 'punctuation.definition.interpolation.end.bracket.curly.scss']

    it 'is tokenized as a class name', ->
      {tokens} = grammar.tokenizeLine 'body.#\{$class} {}'

      expect(tokens[2]).toEqual value: '#{', scopes: ['source.css.scss', 'entity.other.attribute-name.class.css', 'variable.interpolation.scss', 'punctuation.definition.interpolation.begin.bracket.curly.scss']
      expect(tokens[3]).toEqual value: '$class', scopes: ['source.css.scss', 'entity.other.attribute-name.class.css', 'variable.interpolation.scss', 'variable.scss', 'variable.scss']
      expect(tokens[4]).toEqual value: '}', scopes: ['source.css.scss', 'entity.other.attribute-name.class.css', 'variable.interpolation.scss', 'punctuation.definition.interpolation.end.bracket.curly.scss']

    it 'is tokenized as a keyframe', ->
      {tokens} = grammar.tokenizeLine '@keyframes anim { #\{$keyframe} {} }'

      expect(tokens[7]).toEqual value: '#{', scopes: ['source.css.scss', 'meta.at-rule.keyframes.scss', 'meta.keyframes.scss', 'variable.interpolation.scss', 'punctuation.definition.interpolation.begin.bracket.curly.scss']
      expect(tokens[8]).toEqual value: '$keyframe', scopes: ['source.css.scss', 'meta.at-rule.keyframes.scss', 'meta.keyframes.scss', 'variable.interpolation.scss', 'variable.scss', 'variable.scss']
      expect(tokens[9]).toEqual value: '}', scopes: ['source.css.scss', 'meta.at-rule.keyframes.scss', 'meta.keyframes.scss', 'variable.interpolation.scss', 'punctuation.definition.interpolation.end.bracket.curly.scss']

    it 'does not tokenize anything after the closing bracket as interpolation', ->
      {tokens} = grammar.tokenizeLine '#\{variable}hi'

      expect(tokens[3]).not.toEqual value: 'hi', scopes: ['source.css.scss', 'variable.interpolation.scss']

  describe 'comments', ->
    it 'tokenizes line comments', ->
      {tokens} = grammar.tokenizeLine '//Wow a comment!'

      expect(tokens[0]).toEqual value: '//', scopes: ['source.css.scss', 'comment.line.scss', 'punctuation.definition.comment.scss']
      expect(tokens[1]).toEqual value: 'Wow a comment!', scopes: ['source.css.scss', 'comment.line.scss']

    it 'tokenizes block comments', ->
      {tokens} = grammar.tokenizeLine '/*Pretty blocky*/'

      expect(tokens[0]).toEqual value: '/*', scopes: ['source.css.scss', 'comment.block.scss', 'punctuation.definition.comment.scss']
      expect(tokens[1]).toEqual value: 'Pretty blocky', scopes: ['source.css.scss', 'comment.block.scss']
      expect(tokens[2]).toEqual value: '*/', scopes: ['source.css.scss', 'comment.block.scss', 'punctuation.definition.comment.scss']

    it "doesn't tokenize URLs as comments", ->
      tokens = grammar.tokenizeLines '''
        .a {
            background: transparent url(//url/goes/here) 0 0 / cover no-repeat;
        }
      '''

      expect(tokens[1][8]).toEqual value: '//url/goes/here', scopes: ['source.css.scss', 'meta.property-list.scss', 'meta.property-value.scss', 'variable.parameter.url.scss']
