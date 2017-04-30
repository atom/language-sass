describe 'SCSS grammar', ->
  grammar = null

  beforeEach ->
    waitsForPromise ->
      atom.packages.activatePackage('imp-language-sass')

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

      {tokens} = grammar.tokenizeLine '.something { height: 0.2 }'

      expect(tokens[8]).toEqual value: '0.2', scopes: ['source.css.scss', 'meta.property-list.scss', 'meta.property-value.scss', 'constant.numeric.scss']

      {tokens} = grammar.tokenizeLine '.something { height: .2 }'

      expect(tokens[8]).toEqual value: '.2', scopes: ['source.css.scss', 'meta.property-list.scss', 'meta.property-value.scss', 'constant.numeric.scss']

      {tokens} = grammar.tokenizeLine '.something { color: rgba(0, 128, 0, 1) }'
      expect(tokens[10]).toEqual value: '0', scopes: ['source.css.scss', 'meta.property-list.scss', 'meta.property-value.scss', 'constant.numeric.scss']
      expect(tokens[13]).toEqual value: '128', scopes: ['source.css.scss', 'meta.property-list.scss', 'meta.property-value.scss', 'constant.numeric.scss']
      expect(tokens[16]).toEqual value: '0', scopes: ['source.css.scss', 'meta.property-list.scss', 'meta.property-value.scss', 'constant.numeric.scss']
      expect(tokens[19]).toEqual value: '1', scopes: ['source.css.scss', 'meta.property-list.scss', 'meta.property-value.scss', 'constant.numeric.scss']

      {tokens} = grammar.tokenizeLine '$q: (color1:$dark-orange);'

      expect(tokens[4]).toEqual value: 'color1', scopes: ['source.css.scss', 'meta.set.variable.scss', 'meta.set.variable.map.scss', 'support.type.map.key.scss']

    it 'tokenizes number operations', ->
      {tokens} = grammar.tokenizeLine '.something { top: +50%; }'

      expect(tokens[8]).toEqual value: '+', scopes: ['source.css.scss', 'meta.property-list.scss', 'meta.property-value.scss', 'keyword.operator.css']
      expect(tokens[9]).toEqual value: '50', scopes: ['source.css.scss', 'meta.property-list.scss', 'meta.property-value.scss', 'constant.numeric.scss']

      {tokens} = grammar.tokenizeLine '.something { top: 50% - 30%; }'

      expect(tokens[11]).toEqual value: '-', scopes: ['source.css.scss', 'meta.property-list.scss', 'meta.property-value.scss', 'keyword.operator.css']

  describe 'selectors', ->
    # TODO: We need more coverage of selectors
    selectors =
      'class': '.'
      'id': '#'
      'parent': '&'
      'placeholder': '%'

    for scope, selector of selectors
      it "tokenizes complex #{scope} selectors", ->
        {tokens} = grammar.tokenizeLine "#{selector}legit-#\{$selector}-name\\@sm"

        expect(tokens[0]).toEqual value: selector, scopes: ["source.css.scss", "entity.other.attribute-name.#{scope}.css", "punctuation.definition.entity.css"]
        expect(tokens[1]).toEqual value: "legit-", scopes: ["source.css.scss", "entity.other.attribute-name.#{scope}.css"]
        expect(tokens[2]).toEqual value: "#\{", scopes: ["source.css.scss", "entity.other.attribute-name.#{scope}.css", "variable.interpolation.scss", "punctuation.definition.interpolation.begin.bracket.curly.scss"]
        expect(tokens[3]).toEqual value: "$selector", scopes: ["source.css.scss", "entity.other.attribute-name.#{scope}.css", "variable.interpolation.scss", "variable.scss"]
        expect(tokens[4]).toEqual value: "}", scopes: ["source.css.scss", "entity.other.attribute-name.#{scope}.css", "variable.interpolation.scss", "punctuation.definition.interpolation.end.bracket.curly.scss"]
        expect(tokens[5]).toEqual value: "-name", scopes: ["source.css.scss", "entity.other.attribute-name.#{scope}.css"]
        expect(tokens[6]).toEqual value: "\\@", scopes: ["source.css.scss", "entity.other.attribute-name.#{scope}.css", "constant.character.escape.scss"]
        expect(tokens[7]).toEqual value: "sm", scopes: ["source.css.scss", "entity.other.attribute-name.#{scope}.css"]

      it "tokenizes invalid identifiers in #{scope} selectors", ->
        {tokens} = grammar.tokenizeLine "#{selector}legit-#\{$selector}-n}a$me\\@sm"

        expect(tokens[0]).toEqual value: selector, scopes: ["source.css.scss", "entity.other.attribute-name.#{scope}.css", "punctuation.definition.entity.css"]
        expect(tokens[1]).toEqual value: "legit-", scopes: ["source.css.scss", "entity.other.attribute-name.#{scope}.css"]
        expect(tokens[2]).toEqual value: "#\{", scopes: ["source.css.scss", "entity.other.attribute-name.#{scope}.css", "variable.interpolation.scss", "punctuation.definition.interpolation.begin.bracket.curly.scss"]
        expect(tokens[3]).toEqual value: "$selector", scopes: ["source.css.scss", "entity.other.attribute-name.#{scope}.css", "variable.interpolation.scss", "variable.scss"]
        expect(tokens[4]).toEqual value: "}", scopes: ["source.css.scss", "entity.other.attribute-name.#{scope}.css", "variable.interpolation.scss", "punctuation.definition.interpolation.end.bracket.curly.scss"]
        expect(tokens[5]).toEqual value: "-n", scopes: ["source.css.scss", "entity.other.attribute-name.#{scope}.css"]
        expect(tokens[6]).toEqual value: "}", scopes: ["source.css.scss", "entity.other.attribute-name.#{scope}.css", "invalid.illegal.identifier.scss"]
        expect(tokens[7]).toEqual value: "a", scopes: ["source.css.scss", "entity.other.attribute-name.#{scope}.css"]
        expect(tokens[8]).toEqual value: "$", scopes: ["source.css.scss", "entity.other.attribute-name.#{scope}.css", "invalid.illegal.identifier.scss"]
        expect(tokens[9]).toEqual value: "me", scopes: ["source.css.scss", "entity.other.attribute-name.#{scope}.css"]
        expect(tokens[10]).toEqual value: "\\@", scopes: ["source.css.scss", "entity.other.attribute-name.#{scope}.css", "constant.character.escape.scss"]
        expect(tokens[11]).toEqual value: "sm", scopes: ["source.css.scss", "entity.other.attribute-name.#{scope}.css"]

  describe "attribute selectors", ->
    it "tokenizes them correctly", ->
      {tokens} = grammar.tokenizeLine '[something="1"]'

      expect(tokens[0]).toEqual value: '[', scopes: ['source.css.scss', 'meta.attribute-selector.scss', 'punctuation.definition.attribute-selector.begin.bracket.square.scss']
      expect(tokens[1]).toEqual value: 'something', scopes: ['source.css.scss', 'meta.attribute-selector.scss', 'entity.other.attribute-name.attribute.scss']
      expect(tokens[2]).toEqual value: '=', scopes: ['source.css.scss', 'meta.attribute-selector.scss', 'keyword.operator.scss']
      expect(tokens[3]).toEqual value: '"', scopes: ['source.css.scss', 'meta.attribute-selector.scss', 'string.quoted.double.attribute-value.scss', 'punctuation.definition.string.begin.scss']
      expect(tokens[4]).toEqual value: '1', scopes: ['source.css.scss', 'meta.attribute-selector.scss', 'string.quoted.double.attribute-value.scss']
      expect(tokens[5]).toEqual value: '"', scopes: ['source.css.scss', 'meta.attribute-selector.scss', 'string.quoted.double.attribute-value.scss', 'punctuation.definition.string.end.scss']
      expect(tokens[6]).toEqual value: ']', scopes: ['source.css.scss', 'meta.attribute-selector.scss', 'punctuation.definition.attribute-selector.end.bracket.square.scss']

    it "tokenizes complex attribute selectors", ->
      {tokens} = grammar.tokenizeLine "[cla#\{$s}^=abc#\{d}e]"

      expect(tokens[0]).toEqual value: "[", scopes: ["source.css.scss", "meta.attribute-selector.scss", "punctuation.definition.attribute-selector.begin.bracket.square.scss"]
      expect(tokens[1]).toEqual value: "cla", scopes: ["source.css.scss", "meta.attribute-selector.scss", "entity.other.attribute-name.attribute.scss"]
      expect(tokens[2]).toEqual value: "#\{", scopes: ["source.css.scss", "meta.attribute-selector.scss", "entity.other.attribute-name.attribute.scss", "variable.interpolation.scss", "punctuation.definition.interpolation.begin.bracket.curly.scss"]
      expect(tokens[3]).toEqual value: "$s", scopes: ["source.css.scss", "meta.attribute-selector.scss", "entity.other.attribute-name.attribute.scss", "variable.interpolation.scss", "variable.scss"]
      expect(tokens[4]).toEqual value: "}", scopes: ["source.css.scss", "meta.attribute-selector.scss", "entity.other.attribute-name.attribute.scss", "variable.interpolation.scss", "punctuation.definition.interpolation.end.bracket.curly.scss"]
      expect(tokens[5]).toEqual value: "^=", scopes: ["source.css.scss", "meta.attribute-selector.scss", "keyword.operator.scss"]
      expect(tokens[6]).toEqual value: "abc", scopes: ["source.css.scss", "meta.attribute-selector.scss", "string.unquoted.attribute-value.scss"]
      expect(tokens[7]).toEqual value: "#\{", scopes: ["source.css.scss", "meta.attribute-selector.scss", "string.unquoted.attribute-value.scss", "variable.interpolation.scss", "punctuation.definition.interpolation.begin.bracket.curly.scss"]
      expect(tokens[8]).toEqual value: "d", scopes: ["source.css.scss", "meta.attribute-selector.scss", "string.unquoted.attribute-value.scss", "variable.interpolation.scss"]
      expect(tokens[9]).toEqual value: "}", scopes: ["source.css.scss", "meta.attribute-selector.scss", "string.unquoted.attribute-value.scss", "variable.interpolation.scss", "punctuation.definition.interpolation.end.bracket.curly.scss"]
      expect(tokens[10]).toEqual value: "e", scopes: ["source.css.scss", "meta.attribute-selector.scss", "string.unquoted.attribute-value.scss"]
      expect(tokens[11]).toEqual value: "]", scopes: ["source.css.scss", "meta.attribute-selector.scss", "punctuation.definition.attribute-selector.end.bracket.square.scss"]

  describe '@at-root', ->
    it 'tokenizes it correctly', ->
      {tokens} = grammar.tokenizeLine '@at-root (without: media) .btn { color: red; }'

      expect(tokens[0]).toEqual value: '@', scopes: ['source.css.scss', 'meta.at-rule.at-root.scss', 'keyword.control.at-rule.at-root.scss', 'punctuation.definition.keyword.scss']
      expect(tokens[1]).toEqual value: 'at-root', scopes: ['source.css.scss', 'meta.at-rule.at-root.scss', 'keyword.control.at-rule.at-root.scss']

  describe '@include', ->
    it 'tokenizes it correctly', ->
      {tokens} = grammar.tokenizeLine '@include'

      expect(tokens[0]).toEqual value: '@', scopes: ['source.css.scss', 'meta.at-rule.include.scss', 'keyword.control.at-rule.include.scss', 'punctuation.definition.keyword.scss']
      expect(tokens[1]).toEqual value: 'include', scopes: ['source.css.scss', 'meta.at-rule.include.scss', 'keyword.control.at-rule.include.scss']

      {tokens} = grammar.tokenizeLine '@include media{}'

      expect(tokens[0]).toEqual value: '@', scopes: ['source.css.scss', 'meta.at-rule.include.scss', 'keyword.control.at-rule.include.scss', 'punctuation.definition.keyword.scss']
      expect(tokens[1]).toEqual value: 'include', scopes: ['source.css.scss', 'meta.at-rule.include.scss', 'keyword.control.at-rule.include.scss']
      expect(tokens[3]).toEqual value: 'media', scopes: ['source.css.scss', 'meta.at-rule.include.scss', 'entity.name.function.scss']
      expect(tokens[4]).toEqual value: '{', scopes: ['source.css.scss', 'meta.property-list.scss', 'punctuation.section.property-list.begin.bracket.curly.scss']

      {tokens} = grammar.tokenizeLine '@include media($width: 100px){}'

      expect(tokens[3]).toEqual value: 'media', scopes: ['source.css.scss', 'meta.at-rule.include.scss', 'entity.name.function.scss']
      expect(tokens[4]).toEqual value: '(', scopes: ['source.css.scss', 'meta.at-rule.include.scss', 'punctuation.definition.parameters.begin.bracket.round.scss']
      expect(tokens[6]).toEqual value: ':', scopes: ['source.css.scss', 'meta.at-rule.include.scss', 'punctuation.separator.key-value.scss']
      expect(tokens[10]).toEqual value: ')', scopes: ['source.css.scss', 'meta.at-rule.include.scss', 'punctuation.definition.parameters.end.bracket.round.scss']
      expect(tokens[11]).toEqual value: '{', scopes: ['source.css.scss', 'meta.property-list.scss', 'punctuation.section.property-list.begin.bracket.curly.scss']

  describe '@mixin', ->
    it 'tokenizes solitary @mixin correctly', ->
      {tokens} = grammar.tokenizeLine '@mixin'

      expect(tokens[0]).toEqual value: '@', scopes: ['source.css.scss', 'meta.at-rule.mixin.scss', 'keyword.control.at-rule.mixin.scss', 'punctuation.definition.keyword.scss']
      expect(tokens[1]).toEqual value: 'mixin', scopes: ['source.css.scss', 'meta.at-rule.mixin.scss', 'keyword.control.at-rule.mixin.scss']

    it 'tokenizes @mixin with no arguments correctly', ->
      {tokens} = grammar.tokenizeLine '@mixin media{}'

      expect(tokens[0]).toEqual value: '@', scopes: ['source.css.scss', 'meta.at-rule.mixin.scss', 'keyword.control.at-rule.mixin.scss', 'punctuation.definition.keyword.scss']
      expect(tokens[1]).toEqual value: 'mixin', scopes: ['source.css.scss', 'meta.at-rule.mixin.scss', 'keyword.control.at-rule.mixin.scss']
      expect(tokens[3]).toEqual value: 'media', scopes: ['source.css.scss', 'meta.at-rule.mixin.scss', 'entity.name.function.scss']
      expect(tokens[4]).toEqual value: '{', scopes: ['source.css.scss', 'meta.property-list.scss', 'punctuation.section.property-list.begin.bracket.curly.scss']

    it 'tokenizes @mixin with arguments correctly', ->
      {tokens} = grammar.tokenizeLine '@mixin media ($width){}'

      expect(tokens[3]).toEqual value: 'media', scopes: ['source.css.scss', 'meta.at-rule.mixin.scss', 'entity.name.function.scss']
      expect(tokens[5]).toEqual value: '(', scopes: ['source.css.scss', 'meta.at-rule.mixin.scss', 'punctuation.definition.parameters.begin.bracket.round.scss']
      expect(tokens[7]).toEqual value: ')', scopes: ['source.css.scss', 'meta.at-rule.mixin.scss', 'punctuation.definition.parameters.end.bracket.round.scss']
      expect(tokens[8]).toEqual value: '{', scopes: ['source.css.scss', 'meta.property-list.scss', 'punctuation.section.property-list.begin.bracket.curly.scss']

  describe '@namespace', ->
    it 'tokenizes solitary @namespace correctly', ->
      {tokens} = grammar.tokenizeLine '@namespace'

      expect(tokens[0]).toEqual value: '@', scopes: ['source.css.scss', 'meta.at-rule.namespace.scss', 'keyword.control.at-rule.namespace.scss', 'punctuation.definition.keyword.scss']
      expect(tokens[1]).toEqual value: 'namespace', scopes: ['source.css.scss', 'meta.at-rule.namespace.scss', 'keyword.control.at-rule.namespace.scss']

    it 'tokenizes default namespace definition with url() correctly', ->
      {tokens} = grammar.tokenizeLine '@namespace url(XML-namespace-URL);'

      expect(tokens[0]).toEqual value: '@', scopes: ['source.css.scss', 'meta.at-rule.namespace.scss', 'keyword.control.at-rule.namespace.scss', 'punctuation.definition.keyword.scss']
      expect(tokens[1]).toEqual value: 'namespace', scopes: ['source.css.scss', 'meta.at-rule.namespace.scss', 'keyword.control.at-rule.namespace.scss']
      expect(tokens[3]).toEqual value: 'url', scopes: ['source.css.scss', 'meta.at-rule.namespace.scss', 'support.function.misc.scss']

    it 'tokenizes namespace prefix definition with url() correctly', ->
      {tokens} = grammar.tokenizeLine '@namespace prefix url(XML-namespace-URL);'

      expect(tokens[0]).toEqual value: '@', scopes: ['source.css.scss', 'meta.at-rule.namespace.scss', 'keyword.control.at-rule.namespace.scss', 'punctuation.definition.keyword.scss']
      expect(tokens[1]).toEqual value: 'namespace', scopes: ['source.css.scss', 'meta.at-rule.namespace.scss', 'keyword.control.at-rule.namespace.scss']
      expect(tokens[3]).toEqual value: 'prefix', scopes: ['source.css.scss', 'meta.at-rule.namespace.scss', 'entity.name.namespace-prefix.scss']
      expect(tokens[5]).toEqual value: 'url', scopes: ['source.css.scss', 'meta.at-rule.namespace.scss', 'support.function.misc.scss']

  describe '@page', ->
    it 'tokenizes it correctly', ->
      tokens = grammar.tokenizeLines '''
        @page {
          text-align: center;
        }
      '''

      expect(tokens[0][0]).toEqual value: '@', scopes: ['source.css.scss', 'meta.at-rule.page.scss', 'keyword.control.at-rule.page.scss', 'punctuation.definition.keyword.scss']
      expect(tokens[0][1]).toEqual value: 'page', scopes: ['source.css.scss', 'meta.at-rule.page.scss', 'keyword.control.at-rule.page.scss']
      expect(tokens[1][0]).toEqual value: '  ', scopes: ['source.css.scss', 'meta.property-list.scss']
      expect(tokens[1][1]).toEqual value: 'text-align', scopes: ['source.css.scss', 'meta.property-list.scss', 'meta.property-name.scss', 'support.type.property-name.scss']
      expect(tokens[1][2]).toEqual value: ':', scopes: ['source.css.scss', 'meta.property-list.scss', 'punctuation.separator.key-value.scss']
      expect(tokens[1][3]).toEqual value: ' ', scopes: ['source.css.scss', 'meta.property-list.scss']
      expect(tokens[1][4]).toEqual value: 'center', scopes: ['source.css.scss', 'meta.property-list.scss', 'meta.property-value.scss', 'support.constant.property-value.scss']

      tokens = grammar.tokenizeLines '''
        @page :left {
          text-align: center;
        }
      '''

      expect(tokens[0][0]).toEqual value: '@', scopes: ['source.css.scss', 'meta.at-rule.page.scss', 'keyword.control.at-rule.page.scss', 'punctuation.definition.keyword.scss']
      expect(tokens[0][1]).toEqual value: 'page', scopes: ['source.css.scss', 'meta.at-rule.page.scss', 'keyword.control.at-rule.page.scss']
      expect(tokens[0][2]).toEqual value: ' ', scopes: ['source.css.scss', 'meta.at-rule.page.scss']
      expect(tokens[0][3]).toEqual value: ':left', scopes: ['source.css.scss', 'meta.at-rule.page.scss', 'entity.name.function.scss']
      expect(tokens[1][0]).toEqual value: '  ', scopes: ['source.css.scss', 'meta.property-list.scss']
      expect(tokens[1][1]).toEqual value: 'text-align', scopes: ['source.css.scss', 'meta.property-list.scss', 'meta.property-name.scss', 'support.type.property-name.scss']
      expect(tokens[1][2]).toEqual value: ':', scopes: ['source.css.scss', 'meta.property-list.scss', 'punctuation.separator.key-value.scss']
      expect(tokens[1][3]).toEqual value: ' ', scopes: ['source.css.scss', 'meta.property-list.scss']
      expect(tokens[1][4]).toEqual value: 'center', scopes: ['source.css.scss', 'meta.property-list.scss', 'meta.property-value.scss', 'support.constant.property-value.scss']

      tokens = grammar.tokenizeLines '''
        @page:left {
          text-align: center;
        }
      '''

      expect(tokens[0][0]).toEqual value: '@', scopes: ['source.css.scss', 'meta.at-rule.page.scss', 'keyword.control.at-rule.page.scss', 'punctuation.definition.keyword.scss']
      expect(tokens[0][1]).toEqual value: 'page', scopes: ['source.css.scss', 'meta.at-rule.page.scss', 'keyword.control.at-rule.page.scss']
      expect(tokens[0][2]).toEqual value: ':left', scopes: ['source.css.scss', 'meta.at-rule.page.scss', 'entity.name.function.scss']
      expect(tokens[1][0]).toEqual value: '  ', scopes: ['source.css.scss', 'meta.property-list.scss']
      expect(tokens[1][1]).toEqual value: 'text-align', scopes: ['source.css.scss', 'meta.property-list.scss', 'meta.property-name.scss', 'support.type.property-name.scss']
      expect(tokens[1][2]).toEqual value: ':', scopes: ['source.css.scss', 'meta.property-list.scss', 'punctuation.separator.key-value.scss']
      expect(tokens[1][3]).toEqual value: ' ', scopes: ['source.css.scss', 'meta.property-list.scss']
      expect(tokens[1][4]).toEqual value: 'center', scopes: ['source.css.scss', 'meta.property-list.scss', 'meta.property-value.scss', 'support.constant.property-value.scss']

  describe '@supports', ->
    it 'tokenizes solitary @supports', ->
      {tokens} = grammar.tokenizeLine '@supports'

      expect(tokens[0]).toEqual value: '@', scopes: ['source.css.scss', 'meta.at-rule.supports.scss', 'keyword.control.at-rule.supports.scss', 'punctuation.definition.keyword.scss']
      expect(tokens[1]).toEqual value: 'supports', scopes: ['source.css.scss', 'meta.at-rule.supports.scss', 'keyword.control.at-rule.supports.scss']

    it 'tokenizes @supports with negation, testing for "flex" as value', ->
      {tokens} = grammar.tokenizeLine '@supports not ( display: flex ){}'

      expect(tokens[0]).toEqual value: '@', scopes: ['source.css.scss', 'meta.at-rule.supports.scss', 'keyword.control.at-rule.supports.scss', 'punctuation.definition.keyword.scss']
      expect(tokens[1]).toEqual value: 'supports', scopes: ['source.css.scss', 'meta.at-rule.supports.scss', 'keyword.control.at-rule.supports.scss']
      expect(tokens[3]).toEqual value: 'not', scopes: ['source.css.scss', 'meta.at-rule.supports.scss', 'keyword.operator.logical.scss']
      expect(tokens[5]).toEqual value: '(', scopes: ['source.css.scss', 'meta.at-rule.supports.scss', 'punctuation.definition.condition.begin.bracket.round.scss']
      expect(tokens[7]).toEqual value: 'display', scopes: ['source.css.scss', 'meta.at-rule.supports.scss', 'meta.property-name.scss', 'support.type.property-name.scss']
      expect(tokens[8]).toEqual value: ':', scopes: ['source.css.scss', 'meta.at-rule.supports.scss', 'punctuation.separator.key-value.scss']
      expect(tokens[10]).toEqual value: 'flex', scopes: ['source.css.scss', 'meta.at-rule.supports.scss', 'meta.property-value.scss', 'support.constant.property-value.scss']
      expect(tokens[12]).toEqual value: ')', scopes: ['source.css.scss', 'meta.at-rule.supports.scss', 'punctuation.definition.condition.end.bracket.round.scss']
      expect(tokens[13]).toEqual value: '{', scopes: ['source.css.scss', 'meta.property-list.scss', 'punctuation.section.property-list.begin.bracket.curly.scss']

    it 'tokenizes @supports with disjunction, testing for "flex" as property', ->
      {tokens} = grammar.tokenizeLine '@supports (flex:2 2) or (  -webkit-flex  : 2 2)  {}'

      expect(tokens[0]).toEqual value: '@', scopes: ['source.css.scss', 'meta.at-rule.supports.scss', 'keyword.control.at-rule.supports.scss', 'punctuation.definition.keyword.scss']
      expect(tokens[1]).toEqual value: 'supports', scopes: ['source.css.scss', 'meta.at-rule.supports.scss', 'keyword.control.at-rule.supports.scss']
      expect(tokens[3]).toEqual value: '(', scopes: ['source.css.scss', 'meta.at-rule.supports.scss', 'punctuation.definition.condition.begin.bracket.round.scss']
      expect(tokens[4]).toEqual value: 'flex', scopes: ['source.css.scss', 'meta.at-rule.supports.scss', 'meta.property-name.scss', 'support.type.property-name.scss']
      expect(tokens[5]).toEqual value: ':', scopes: ['source.css.scss', 'meta.at-rule.supports.scss', 'punctuation.separator.key-value.scss']
      expect(tokens[6]).toEqual value: '2', scopes: ['source.css.scss', 'meta.at-rule.supports.scss', 'meta.property-value.scss', 'constant.numeric.scss']
      expect(tokens[9]).toEqual value: ')', scopes: ['source.css.scss', 'meta.at-rule.supports.scss', 'punctuation.definition.condition.end.bracket.round.scss']
      expect(tokens[11]).toEqual value: 'or', scopes: ['source.css.scss', 'meta.at-rule.supports.scss', 'keyword.operator.logical.scss']
      expect(tokens[15]).toEqual value: '-webkit-flex', scopes: ['source.css.scss', 'meta.at-rule.supports.scss', 'meta.property-name.scss', 'support.type.property-name.scss']
      expect(tokens[17]).toEqual value: ':', scopes: ['source.css.scss', 'meta.at-rule.supports.scss', 'punctuation.separator.key-value.scss']
      expect(tokens[19]).toEqual value: '2', scopes: ['source.css.scss', 'meta.at-rule.supports.scss', 'meta.property-value.scss', 'constant.numeric.scss']
      expect(tokens[24]).toEqual value: '{', scopes: ['source.css.scss', 'meta.property-list.scss', 'punctuation.section.property-list.begin.bracket.curly.scss']

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
      tokens = grammar.tokenizeLines '''
        very-custom { color: inherit }
        another-one { display: none; }
      '''

      expect(tokens[0][0]).toEqual value: 'very-custom', scopes: ['source.css.scss', 'entity.name.tag.custom.scss']
      expect(tokens[0][4]).toEqual value: 'color', scopes: ['source.css.scss', 'meta.property-list.scss', 'meta.property-name.scss', 'support.type.property-name.scss']
      expect(tokens[0][7]).toEqual value: 'inherit', scopes: ['source.css.scss', 'meta.property-list.scss', 'meta.property-value.scss', 'support.constant.property-value.scss']
      expect(tokens[0][9]).toEqual value: '}', scopes: ['source.css.scss', 'meta.property-list.scss', 'punctuation.section.property-list.end.bracket.curly.scss']
      expect(tokens[1][0]).toEqual value: 'another-one', scopes: ['source.css.scss', 'entity.name.tag.custom.scss']
      expect(tokens[1][10]).toEqual value: '}', scopes: ['source.css.scss', 'meta.property-list.scss', 'punctuation.section.property-list.end.bracket.curly.scss']

    describe 'property values', ->
      it 'tokenizes parentheses', ->
        {tokens} = grammar.tokenizeLine '.foo { margin: ($bar * .8) 0 ($bar * .8) ($bar * 2);'
        expect(tokens[8]).toEqual value: '(', scopes: ['source.css.scss', 'meta.property-list.scss', 'meta.property-value.scss', 'punctuation.definition.begin.bracket.round.scss']
        expect(tokens[9]).toEqual value: '$bar', scopes: ['source.css.scss', 'meta.property-list.scss', 'meta.property-value.scss', 'variable.scss']
        expect(tokens[11]).toEqual value: '*', scopes: ['source.css.scss', 'meta.property-list.scss', 'meta.property-value.scss', 'keyword.operator.css']
        expect(tokens[13]).toEqual value: '.8', scopes: ['source.css.scss', 'meta.property-list.scss', 'meta.property-value.scss', 'constant.numeric.scss']
        expect(tokens[14]).toEqual value: ')', scopes: ['source.css.scss', 'meta.property-list.scss', 'meta.property-value.scss', 'punctuation.definition.end.bracket.round.scss']
        expect(tokens[16]).toEqual value: '0', scopes: ['source.css.scss', 'meta.property-list.scss', 'meta.property-value.scss', 'constant.numeric.scss']
        expect(tokens[18]).toEqual value: '(', scopes: ['source.css.scss', 'meta.property-list.scss', 'meta.property-value.scss', 'punctuation.definition.begin.bracket.round.scss']
        expect(tokens[19]).toEqual value: '$bar', scopes: ['source.css.scss', 'meta.property-list.scss', 'meta.property-value.scss', 'variable.scss']
        expect(tokens[21]).toEqual value: '*', scopes: ['source.css.scss', 'meta.property-list.scss', 'meta.property-value.scss', 'keyword.operator.css']
        expect(tokens[23]).toEqual value: '.8', scopes: ['source.css.scss', 'meta.property-list.scss', 'meta.property-value.scss', 'constant.numeric.scss']
        expect(tokens[24]).toEqual value: ')', scopes: ['source.css.scss', 'meta.property-list.scss', 'meta.property-value.scss', 'punctuation.definition.end.bracket.round.scss']
        expect(tokens[26]).toEqual value: '(', scopes: ['source.css.scss', 'meta.property-list.scss', 'meta.property-value.scss', 'punctuation.definition.begin.bracket.round.scss']
        expect(tokens[27]).toEqual value: '$bar', scopes: ['source.css.scss', 'meta.property-list.scss', 'meta.property-value.scss', 'variable.scss']
        expect(tokens[29]).toEqual value: '*', scopes: ['source.css.scss', 'meta.property-list.scss', 'meta.property-value.scss', 'keyword.operator.css']
        expect(tokens[31]).toEqual value: '2', scopes: ['source.css.scss', 'meta.property-list.scss', 'meta.property-value.scss', 'constant.numeric.scss']
        expect(tokens[32]).toEqual value: ')', scopes: ['source.css.scss', 'meta.property-list.scss', 'meta.property-value.scss', 'punctuation.definition.end.bracket.round.scss']

  describe 'property names with a prefix that matches an element name', ->
    it 'does not confuse them with properties', ->
      tokens = grammar.tokenizeLines '''
        text {
          text-align: center;
        }
      '''

      expect(tokens[0][0]).toEqual value: 'text', scopes: ['source.css.scss', 'entity.name.tag.scss']
      expect(tokens[1][0]).toEqual value: '  ', scopes: ['source.css.scss', 'meta.property-list.scss']
      expect(tokens[1][1]).toEqual value: 'text-align', scopes: ['source.css.scss', 'meta.property-list.scss', 'meta.property-name.scss', 'support.type.property-name.scss']
      expect(tokens[1][2]).toEqual value: ':', scopes: ['source.css.scss', 'meta.property-list.scss', 'punctuation.separator.key-value.scss']
      expect(tokens[1][3]).toEqual value: ' ', scopes: ['source.css.scss', 'meta.property-list.scss']
      expect(tokens[1][4]).toEqual value: 'center', scopes: ['source.css.scss', 'meta.property-list.scss', 'meta.property-value.scss', 'support.constant.property-value.scss']

      tokens = grammar.tokenizeLines '''
        table {
          table-layout: fixed;
        }
      '''

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
      expect(tokens[1]).toEqual value: ':', scopes: ['source.css.scss', 'entity.other.attribute-name.pseudo-class.css', 'punctuation.definition.entity.css']
      expect(tokens[2]).toEqual value: 'hover', scopes: ['source.css.scss', 'entity.other.attribute-name.pseudo-class.css']

    it 'tokenizes them with class selectors', ->
      {tokens} = grammar.tokenizeLine 'very-custom.class { color: red; }'

      expect(tokens[0]).toEqual value: 'very-custom', scopes: ['source.css.scss', 'entity.name.tag.custom.scss']
      expect(tokens[1]).toEqual value: '.', scopes: ['source.css.scss', 'entity.other.attribute-name.class.css', 'punctuation.definition.entity.css']
      expect(tokens[2]).toEqual value: 'class', scopes: ['source.css.scss', 'entity.other.attribute-name.class.css']

    it "tokenizes them with attribute selectors", ->
      {tokens} = grammar.tokenizeLine "md-toolbar[color='primary']"

      expect(tokens[0]).toEqual value: "md-toolbar", scopes: ["source.css.scss", "entity.name.tag.custom.scss"]
      expect(tokens[1]).toEqual value: "[", scopes: ["source.css.scss", "meta.attribute-selector.scss", "punctuation.definition.attribute-selector.begin.bracket.square.scss"]
      expect(tokens[2]).toEqual value: "color", scopes: ["source.css.scss", "meta.attribute-selector.scss", "entity.other.attribute-name.attribute.scss"]
      expect(tokens[3]).toEqual value: "=", scopes: ["source.css.scss", "meta.attribute-selector.scss", "keyword.operator.scss"]
      expect(tokens[4]).toEqual value: "'", scopes: ["source.css.scss", "meta.attribute-selector.scss", "string.quoted.single.attribute-value.scss", "punctuation.definition.string.begin.scss"]
      expect(tokens[5]).toEqual value: "primary", scopes: ["source.css.scss", "meta.attribute-selector.scss", "string.quoted.single.attribute-value.scss"]
      expect(tokens[6]).toEqual value: "'", scopes: ["source.css.scss", "meta.attribute-selector.scss", "string.quoted.single.attribute-value.scss", "punctuation.definition.string.end.scss"]
      expect(tokens[7]).toEqual value: ']', scopes: ["source.css.scss", "meta.attribute-selector.scss", "punctuation.definition.attribute-selector.end.bracket.square.scss"]

    it 'does not confuse them with properties', ->
      tokens = grammar.tokenizeLines '''
        body {
          border-width: 2;
          font-size : 2;
          background-image  : none;
        }
      '''

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

      expect(tokens[1]).toEqual value: ':', scopes: ['source.css.scss', 'entity.other.attribute-name.pseudo-class.css', 'punctuation.definition.entity.css']
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

    it "tokenizes complex pseudo classes", ->
      {tokens} = grammar.tokenizeLine "&:nth-child(#\{$j})"

      expect(tokens[0]).toEqual value: "&", scopes: ["source.css.scss", "entity.name.tag.reference.scss"]
      expect(tokens[1]).toEqual value: ":", scopes: ["source.css.scss", "entity.other.attribute-name.pseudo-class.css", "punctuation.definition.entity.css"]
      expect(tokens[2]).toEqual value: "nth-child", scopes: ["source.css.scss", "entity.other.attribute-name.pseudo-class.css"]
      expect(tokens[3]).toEqual value: "(", scopes: ["source.css.scss", "punctuation.definition.pseudo-class.begin.bracket.round.css"]
      expect(tokens[4]).toEqual value: "#\{", scopes: ["source.css.scss", "variable.interpolation.scss", "punctuation.definition.interpolation.begin.bracket.curly.scss"]
      expect(tokens[5]).toEqual value: "$j", scopes: ["source.css.scss", "variable.interpolation.scss", "variable.scss"]
      expect(tokens[6]).toEqual value: "}", scopes: ["source.css.scss", "variable.interpolation.scss", "punctuation.definition.interpolation.end.bracket.curly.scss"]
      expect(tokens[7]).toEqual value: ")", scopes: ["source.css.scss", "punctuation.definition.pseudo-class.end.bracket.round.css"]

  describe '@keyframes', ->
    it 'parses the from and to properties', ->
      tokens = grammar.tokenizeLines '''
        @keyframes anim {
          from { opacity: 0; }
          to { opacity: 1; }
        }
      '''

      expect(tokens[0][0]).toEqual value: '@', scopes: ['source.css.scss', 'meta.at-rule.keyframes.scss', 'keyword.control.at-rule.keyframes.scss', 'punctuation.definition.keyword.scss']
      expect(tokens[0][1]).toEqual value: 'keyframes', scopes: ['source.css.scss', 'meta.at-rule.keyframes.scss', 'keyword.control.at-rule.keyframes.scss']
      expect(tokens[0][2]).toEqual value: ' ', scopes: ['source.css.scss', 'meta.at-rule.keyframes.scss']
      expect(tokens[0][3]).toEqual value: 'anim', scopes: ['source.css.scss', 'meta.at-rule.keyframes.scss', 'entity.name.function.scss']
      expect(tokens[0][5]).toEqual value: '{', scopes: ['source.css.scss', 'meta.at-rule.keyframes.scss', 'punctuation.section.keyframes.begin.scss']
      expect(tokens[1][1]).toEqual value: 'from', scopes: ['source.css.scss', 'meta.at-rule.keyframes.scss', 'entity.other.attribute-name.scss']
      expect(tokens[1][5]).toEqual value: 'opacity', scopes: ['source.css.scss', 'meta.at-rule.keyframes.scss', 'meta.property-list.scss', 'meta.property-name.scss', 'support.type.property-name.scss']
      expect(tokens[1][8]).toEqual value: '0', scopes: ['source.css.scss', 'meta.at-rule.keyframes.scss', 'meta.property-list.scss', 'meta.property-value.scss', 'constant.numeric.scss']
      expect(tokens[2][1]).toEqual value: 'to', scopes: ['source.css.scss', 'meta.at-rule.keyframes.scss', 'entity.other.attribute-name.scss']
      expect(tokens[2][5]).toEqual value: 'opacity', scopes: ['source.css.scss', 'meta.at-rule.keyframes.scss', 'meta.property-list.scss', 'meta.property-name.scss', 'support.type.property-name.scss']
      expect(tokens[2][8]).toEqual value: '1', scopes: ['source.css.scss', 'meta.at-rule.keyframes.scss', 'meta.property-list.scss', 'meta.property-value.scss', 'constant.numeric.scss']
      expect(tokens[3][0]).toEqual value: '}', scopes: ['source.css.scss', 'meta.at-rule.keyframes.scss', 'punctuation.section.keyframes.end.scss']

    describe 'when animation-name is specified as a string', ->
      it 'can be double-quoted, containing escapes', ->
        {tokens} = grammar.tokenizeLine '@keyframes "\\22 foo\\"" {}'

        expect(tokens[3]).toEqual value: '"', scopes: ['source.css.scss', 'meta.at-rule.keyframes.scss', 'string.quoted.double.scss', 'punctuation.definition.string.begin.scss']
        expect(tokens[4]).toEqual value: '\\22', scopes: ['source.css.scss', 'meta.at-rule.keyframes.scss', 'string.quoted.double.scss', 'entity.name.function.scss', 'constant.character.escape.scss']
        expect(tokens[7]).toEqual value: '"', scopes: ['source.css.scss', 'meta.at-rule.keyframes.scss', 'string.quoted.double.scss', 'punctuation.definition.string.end.scss']
        expect(tokens[9]).toEqual value: '{', scopes: ['source.css.scss', 'meta.at-rule.keyframes.scss', 'punctuation.section.keyframes.begin.scss']

      it 'can be single-quoted, containing escapes', ->
        {tokens} = grammar.tokenizeLine "@keyframes '\\'foo\\27' {}"

        expect(tokens[3]).toEqual value: "'", scopes: ['source.css.scss', 'meta.at-rule.keyframes.scss', 'string.quoted.single.scss', 'punctuation.definition.string.begin.scss']
        expect(tokens[6]).toEqual value: '\\27', scopes: ['source.css.scss', 'meta.at-rule.keyframes.scss', 'string.quoted.single.scss', 'entity.name.function.scss', 'constant.character.escape.scss']
        expect(tokens[7]).toEqual value: "'", scopes: ['source.css.scss', 'meta.at-rule.keyframes.scss', 'string.quoted.single.scss', 'punctuation.definition.string.end.scss']
        expect(tokens[9]).toEqual value: '{', scopes: ['source.css.scss', 'meta.at-rule.keyframes.scss', 'punctuation.section.keyframes.begin.scss']

  describe 'media queries', ->
    it 'parses media types and features', ->
      {tokens} = grammar.tokenizeLine '@media (orientation: landscape) and only screen and (min-width: 700px) /* comment */ {}'

      expect(tokens[0]).toEqual value: '@', scopes: ['source.css.scss', 'meta.at-rule.media.scss', 'keyword.control.at-rule.media.scss', 'punctuation.definition.keyword.scss']
      expect(tokens[1]).toEqual value: 'media', scopes: ['source.css.scss', 'meta.at-rule.media.scss', 'keyword.control.at-rule.media.scss']
      expect(tokens[2]).toEqual value: ' ', scopes: ['source.css.scss', 'meta.at-rule.media.scss']
      expect(tokens[3]).toEqual value: '(', scopes: ['source.css.scss', 'meta.at-rule.media.scss', 'meta.property-list.media-query.scss', 'punctuation.definition.media-query.begin.bracket.round.scss']
      expect(tokens[4]).toEqual value: 'orientation', scopes: ['source.css.scss', 'meta.at-rule.media.scss', 'meta.property-list.media-query.scss', 'meta.property-name.media-query.scss', 'support.type.property-name.media.css']
      expect(tokens[5]).toEqual value: ':', scopes: ['source.css.scss', 'meta.at-rule.media.scss', 'meta.property-list.media-query.scss', 'punctuation.separator.key-value.scss']
      expect(tokens[6]).toEqual value: ' ', scopes: ['source.css.scss', 'meta.at-rule.media.scss', 'meta.property-list.media-query.scss']
      expect(tokens[7]).toEqual value: 'landscape', scopes: ['source.css.scss', 'meta.at-rule.media.scss', 'meta.property-list.media-query.scss', 'meta.property-value.media-query.scss', 'support.constant.property-value.scss']
      expect(tokens[8]).toEqual value: ')', scopes: ['source.css.scss', 'meta.at-rule.media.scss', 'meta.property-list.media-query.scss', 'punctuation.definition.media-query.end.bracket.round.scss']
      expect(tokens[9]).toEqual value: ' ', scopes: ['source.css.scss', 'meta.at-rule.media.scss']
      expect(tokens[10]).toEqual value: 'and', scopes: ['source.css.scss', 'meta.at-rule.media.scss', 'keyword.operator.logical.scss']
      expect(tokens[12]).toEqual value: 'only', scopes: ['source.css.scss', 'meta.at-rule.media.scss', 'keyword.control.operator']
      expect(tokens[14]).toEqual value: 'screen', scopes: ['source.css.scss', 'meta.at-rule.media.scss', 'support.constant.media.css']
      expect(tokens[16]).toEqual value: 'and', scopes: ['source.css.scss', 'meta.at-rule.media.scss', 'keyword.operator.logical.scss']
      expect(tokens[18]).toEqual value: '(', scopes: ['source.css.scss', 'meta.at-rule.media.scss', 'meta.property-list.media-query.scss', 'punctuation.definition.media-query.begin.bracket.round.scss']
      expect(tokens[19]).toEqual value: 'min-width', scopes: ['source.css.scss', 'meta.at-rule.media.scss', 'meta.property-list.media-query.scss', 'meta.property-name.media-query.scss', 'support.type.property-name.media.css']
      expect(tokens[20]).toEqual value: ':', scopes: ['source.css.scss', 'meta.at-rule.media.scss', 'meta.property-list.media-query.scss', 'punctuation.separator.key-value.scss']
      expect(tokens[22]).toEqual value: '700', scopes: ['source.css.scss', 'meta.at-rule.media.scss', 'meta.property-list.media-query.scss', 'meta.property-value.media-query.scss', 'constant.numeric.scss']
      expect(tokens[23]).toEqual value: 'px', scopes: ['source.css.scss', 'meta.at-rule.media.scss', 'meta.property-list.media-query.scss', 'meta.property-value.media-query.scss', 'keyword.other.unit.scss']
      expect(tokens[24]).toEqual value: ')', scopes: ['source.css.scss', 'meta.at-rule.media.scss', 'meta.property-list.media-query.scss', 'punctuation.definition.media-query.end.bracket.round.scss']
      expect(tokens[26]).toEqual value: '/*', scopes: ['source.css.scss', 'meta.at-rule.media.scss', 'comment.block.scss', 'punctuation.definition.comment.scss']
      expect(tokens[30]).toEqual value: '{', scopes: ['source.css.scss', 'meta.property-list.scss', 'punctuation.section.property-list.begin.bracket.curly.scss']

  describe 'functions', ->
    it 'parses them', ->
      {tokens} = grammar.tokenizeLine '.a { hello: something($wow, 3) }'

      expect(tokens[8]).toEqual value: 'something', scopes: ['source.css.scss', 'meta.property-list.scss', 'meta.property-value.scss', 'support.function.misc.scss']
      expect(tokens[9]).toEqual value: '(', scopes: ['source.css.scss', 'meta.property-list.scss', 'meta.property-value.scss', 'punctuation.section.function.scss']
      expect(tokens[10]).toEqual value: '$wow', scopes: ['source.css.scss', 'meta.property-list.scss', 'meta.property-value.scss', 'variable.scss']
      expect(tokens[11]).toEqual value: ',', scopes: ['source.css.scss', 'meta.property-list.scss', 'meta.property-value.scss', 'punctuation.separator.delimiter.scss']
      expect(tokens[13]).toEqual value: '3', scopes: ['source.css.scss', 'meta.property-list.scss', 'meta.property-value.scss', 'constant.numeric.scss']
      expect(tokens[14]).toEqual value: ')', scopes: ['source.css.scss', 'meta.property-list.scss', 'meta.property-value.scss', 'punctuation.section.function.scss']

    it 'tokenizes functions with parentheses in them', ->
      {tokens} = grammar.tokenizeLine '.a { hello: something((a: $b)) }'

      expect(tokens[8]).toEqual value: 'something', scopes: ['source.css.scss', 'meta.property-list.scss', 'meta.property-value.scss', 'support.function.misc.scss']
      expect(tokens[9]).toEqual value: '(', scopes: ['source.css.scss', 'meta.property-list.scss', 'meta.property-value.scss', 'punctuation.section.function.scss']
      expect(tokens[10]).toEqual value: '(', scopes: ['source.css.scss', 'meta.property-list.scss', 'meta.property-value.scss', 'punctuation.definition.begin.bracket.round.scss']
      expect(tokens[11]).toEqual value: 'a', scopes: ['source.css.scss', 'meta.property-list.scss', 'meta.property-value.scss']
      expect(tokens[12]).toEqual value: ':', scopes: ['source.css.scss', 'meta.property-list.scss', 'meta.property-value.scss', 'punctuation.separator.key-value.scss']
      expect(tokens[14]).toEqual value: '$b', scopes: ['source.css.scss', 'meta.property-list.scss', 'meta.property-value.scss', 'variable.scss']
      expect(tokens[15]).toEqual value: ')', scopes: ['source.css.scss', 'meta.property-list.scss', 'meta.property-value.scss', 'punctuation.definition.end.bracket.round.scss']
      expect(tokens[16]).toEqual value: ')', scopes: ['source.css.scss', 'meta.property-list.scss', 'meta.property-value.scss', 'punctuation.section.function.scss']

  describe 'variable setting', ->
    it 'parses all tokens', ->
      {tokens} = grammar.tokenizeLine '$font-size: $normal-font-size;'

      expect(tokens[0]).toEqual value: '$font-size', scopes: ['source.css.scss', 'meta.set.variable.scss', 'variable.scss']
      expect(tokens[1]).toEqual value: ':', scopes: ['source.css.scss', 'meta.set.variable.scss', 'punctuation.separator.key-value.scss']
      expect(tokens[2]).toEqual value: ' ', scopes: ['source.css.scss', 'meta.set.variable.scss']
      expect(tokens[3]).toEqual value: '$normal-font-size', scopes: ['source.css.scss', 'meta.set.variable.scss', 'variable.scss']

    it "parses css variables", ->
      {tokens} = grammar.tokenizeLine(".foo { --spacing-unit: 6px; }")
      expect(tokens).toHaveLength 13
      expect(tokens[0]).toEqual value: ".", scopes: ['source.css.scss', 'entity.other.attribute-name.class.css', 'punctuation.definition.entity.css']
      expect(tokens[1]).toEqual value: "foo", scopes: ['source.css.scss', 'entity.other.attribute-name.class.css']
      expect(tokens[2]).toEqual value: " ", scopes: ['source.css.scss']
      expect(tokens[3]).toEqual value: "{", scopes: [ 'source.css.scss', 'meta.property-list.scss', 'punctuation.section.property-list.begin.bracket.curly.scss' ]
      expect(tokens[4]).toEqual value: " ", scopes: ['source.css.scss', 'meta.property-list.scss']
      expect(tokens[5]).toEqual value: "--spacing-unit", scopes: ['source.css.scss', 'meta.property-list.scss', 'variable.scss']
      expect(tokens[6]).toEqual value: ":", scopes: [ 'source.css.scss', 'meta.property-list.scss', 'punctuation.separator.key-value.scss' ]
      expect(tokens[7]).toEqual value: " ", scopes: ['source.css.scss', 'meta.property-list.scss']
      expect(tokens[8]).toEqual value: "6", scopes: [ 'source.css.scss', 'meta.property-list.scss', 'meta.property-value.scss', 'constant.numeric.scss' ]
      expect(tokens[9]).toEqual value: "px", scopes: [ 'source.css.scss', 'meta.property-list.scss', 'meta.property-value.scss', 'keyword.other.unit.scss' ]
      expect(tokens[10]).toEqual value: ";", scopes: [ 'source.css.scss', 'meta.property-list.scss', 'punctuation.terminator.rule.scss' ]
      expect(tokens[11]).toEqual value: " ", scopes: ['source.css.scss', 'meta.property-list.scss']
      expect(tokens[12]).toEqual value: "}", scopes: [ 'source.css.scss', 'meta.property-list.scss', 'punctuation.section.property-list.end.bracket.curly.scss' ]

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

    it 'tokenizes variables in maps', ->
      {tokens} = grammar.tokenizeLine '$map: (gutters: $grid-content-gutters)'

      expect(tokens[7]).toEqual value: '$grid-content-gutters', scopes: ['source.css.scss', 'meta.set.variable.scss', 'meta.set.variable.map.scss', 'variable.scss']

    it 'tokenizes maps inside maps', ->
      tokens = grammar.tokenizeLines '''
        $custom-palettes: (
          alr: (
            alr-blue: (
              x-light: rgb(240, 243, 246)
            )
          )
        );
      '''

      expect(tokens[1][1]).toEqual value: 'alr', scopes: ['source.css.scss', 'meta.set.variable.scss', 'meta.set.variable.map.scss', 'support.type.map.key.scss']
      expect(tokens[2][1]).toEqual value: 'alr-blue', scopes: ['source.css.scss', 'meta.set.variable.scss', 'meta.set.variable.map.scss', 'meta.set.variable.map.scss', 'support.type.map.key.scss']
      expect(tokens[3][1]).toEqual value: 'x-light', scopes: ['source.css.scss', 'meta.set.variable.scss', 'meta.set.variable.map.scss', 'meta.set.variable.map.scss', 'meta.set.variable.map.scss', 'support.type.map.key.scss']

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
      expect(tokens[9]).toEqual value: '$family', scopes: ['source.css.scss', 'meta.property-list.scss', 'meta.property-value.scss', 'string.quoted.single.scss', 'variable.interpolation.scss', 'variable.scss']
      expect(tokens[10]).toEqual value: '}', scopes: ['source.css.scss', 'meta.property-list.scss', 'meta.property-value.scss', 'string.quoted.single.scss', 'variable.interpolation.scss', 'punctuation.definition.interpolation.end.bracket.curly.scss']

    it 'is tokenized within double quotes', ->
      {tokens} = grammar.tokenizeLine 'body { font-family: "#\{$family}"; }'

      expect(tokens[8]).toEqual value: '#{', scopes: ['source.css.scss', 'meta.property-list.scss', 'meta.property-value.scss', 'string.quoted.double.scss', 'variable.interpolation.scss', 'punctuation.definition.interpolation.begin.bracket.curly.scss']
      expect(tokens[9]).toEqual value: '$family', scopes: ['source.css.scss', 'meta.property-list.scss', 'meta.property-value.scss', 'string.quoted.double.scss', 'variable.interpolation.scss', 'variable.scss']
      expect(tokens[10]).toEqual value: '}', scopes: ['source.css.scss', 'meta.property-list.scss', 'meta.property-value.scss', 'string.quoted.double.scss', 'variable.interpolation.scss', 'punctuation.definition.interpolation.end.bracket.curly.scss']

    it 'is tokenized without quotes', ->
      {tokens} = grammar.tokenizeLine 'body { font-family: #\{$family}; }'

      expect(tokens[7]).toEqual value: '#{', scopes: ['source.css.scss', 'meta.property-list.scss', 'meta.property-value.scss', 'variable.interpolation.scss', 'punctuation.definition.interpolation.begin.bracket.curly.scss']
      expect(tokens[8]).toEqual value: '$family', scopes: ['source.css.scss', 'meta.property-list.scss', 'meta.property-value.scss', 'variable.interpolation.scss', 'variable.scss']
      expect(tokens[9]).toEqual value: '}', scopes: ['source.css.scss', 'meta.property-list.scss', 'meta.property-value.scss', 'variable.interpolation.scss', 'punctuation.definition.interpolation.end.bracket.curly.scss']

    it 'is tokenized as a class name', ->
      {tokens} = grammar.tokenizeLine 'body.#\{$class} {}'

      expect(tokens[2]).toEqual value: '#{', scopes: ['source.css.scss', 'entity.other.attribute-name.class.css', 'variable.interpolation.scss', 'punctuation.definition.interpolation.begin.bracket.curly.scss']
      expect(tokens[3]).toEqual value: '$class', scopes: ['source.css.scss', 'entity.other.attribute-name.class.css', 'variable.interpolation.scss', 'variable.scss']
      expect(tokens[4]).toEqual value: '}', scopes: ['source.css.scss', 'entity.other.attribute-name.class.css', 'variable.interpolation.scss', 'punctuation.definition.interpolation.end.bracket.curly.scss']

    it 'is tokenized as a keyframe', ->
      {tokens} = grammar.tokenizeLine '@keyframes anim { #\{$keyframe} {} }'

      expect(tokens[7]).toEqual value: '#{', scopes: ['source.css.scss', 'meta.at-rule.keyframes.scss', 'variable.interpolation.scss', 'punctuation.definition.interpolation.begin.bracket.curly.scss']
      expect(tokens[8]).toEqual value: '$keyframe', scopes: ['source.css.scss', 'meta.at-rule.keyframes.scss', 'variable.interpolation.scss', 'variable.scss']
      expect(tokens[9]).toEqual value: '}', scopes: ['source.css.scss', 'meta.at-rule.keyframes.scss', 'variable.interpolation.scss', 'punctuation.definition.interpolation.end.bracket.curly.scss']

    it 'does not tokenize anything after the closing bracket as interpolation', ->
      {tokens} = grammar.tokenizeLine '#\{variable}hi'

      expect(tokens[3]).not.toEqual value: 'hi', scopes: ['source.css.scss', 'variable.interpolation.scss']

  describe 'strings', ->
    it 'tokenizes single-quote strings', ->
      {tokens} = grammar.tokenizeLine ".a { content: 'hi' }"

      expect(tokens[8]).toEqual value: "'", scopes: ['source.css.scss', 'meta.property-list.scss', 'meta.property-value.scss', 'string.quoted.single.scss', 'punctuation.definition.string.begin.scss']
      expect(tokens[9]).toEqual value: 'hi', scopes: ['source.css.scss', 'meta.property-list.scss', 'meta.property-value.scss', 'string.quoted.single.scss']
      expect(tokens[10]).toEqual value: "'", scopes: ['source.css.scss', 'meta.property-list.scss', 'meta.property-value.scss', 'string.quoted.single.scss', 'punctuation.definition.string.end.scss']

    it 'tokenizes double-quote strings', ->
      {tokens} = grammar.tokenizeLine '.a { content: "hi" }'

      expect(tokens[8]).toEqual value: '"', scopes: ['source.css.scss', 'meta.property-list.scss', 'meta.property-value.scss', 'string.quoted.double.scss', 'punctuation.definition.string.begin.scss']
      expect(tokens[9]).toEqual value: 'hi', scopes: ['source.css.scss', 'meta.property-list.scss', 'meta.property-value.scss', 'string.quoted.double.scss']
      expect(tokens[10]).toEqual value: '"', scopes: ['source.css.scss', 'meta.property-list.scss', 'meta.property-value.scss', 'string.quoted.double.scss', 'punctuation.definition.string.end.scss']

    it 'tokenizes escape characters', ->
      {tokens} = grammar.tokenizeLine ".a { content: '\\abcdef' }"

      expect(tokens[9]).toEqual value: '\\abcdef', scopes: ['source.css.scss', 'meta.property-list.scss', 'meta.property-value.scss', 'string.quoted.single.scss', 'constant.character.escape.scss']

      {tokens} = grammar.tokenizeLine '.a { content: "\\abcdef" }'

      expect(tokens[9]).toEqual value: '\\abcdef', scopes: ['source.css.scss', 'meta.property-list.scss', 'meta.property-value.scss', 'string.quoted.double.scss', 'constant.character.escape.scss']

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

    it 'tokenizes comments in @keyframes', ->
      tokens = grammar.tokenizeLines '''
        @keyframes foo {
          // comment
          /* comment */
        }
      '''

      expect(tokens[1][1]).toEqual value: '//', scopes: ['source.css.scss', 'meta.at-rule.keyframes.scss', 'comment.line.scss', 'punctuation.definition.comment.scss']
      expect(tokens[2][1]).toEqual value: '/*', scopes: ['source.css.scss', 'meta.at-rule.keyframes.scss', 'comment.block.scss', 'punctuation.definition.comment.scss']
      expect(tokens[2][3]).toEqual value: '*/', scopes: ['source.css.scss', 'meta.at-rule.keyframes.scss', 'comment.block.scss', 'punctuation.definition.comment.scss']
