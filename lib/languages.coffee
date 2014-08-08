# # Supported Languages

module.exports = LANGUAGES =
  Markdown:
    nameMatchers: ['.md', '.txt', '.litcoffee', ".markdown"]
    commentsOnly: true

  ActionScript:
    nameMatchers: ['.as']
    lexer: 'actionscript'
    singleLineComment: ['//']

  CSharp:
    nameMatchers: ['.cs']
    lexer: 'cs'
    singleLineComment: ['//']

  CSS:
    nameMatchers: ['.css']
    lexer: 'css'
    singleLineComment: ['/*-']

  CPP:
    nameMatchers: ['.c', '.h', '.cpp', '.hpp', '.c++', '.h++', '.cc', '.hh', '.cxx', '.hxx']
    lexer: 'cpp'
    singleLineComment: ['//']

  Clojure:
    nameMatchers: ['.clj']
    lexer: 'clojure'
    singleLineComment: [';;']

  CoffeeScript:
    nameMatchers: ['.coffee', 'Cakefile']
    lexer: 'coffeescript'
    singleLineComment: ['#']
    multiLineComment: [///^\s*###\s*$///]

  Go:
    nameMatchers: ['.go']
    lexer: 'go'
    singleLineComment: ['//']

  Haskell:
    nameMatchers: ['.hs']
    lexer: 'haskell'
    singleLineComment: ['--']

  Ini:
    nameMatchers: ['.ini']
    lexer: 'ini'
    singleLineComment: [';']

  # TODO: use Jade lexer
  Jade:
    nameMatchers: ['.jade']
    lexer: 'javascript'
    singleLineComment: ['//-', '//']

  Java:
    nameMatchers: ['.java']
    lexer: 'java'
    singleLineComment: ['//']

  JavaScript:
    nameMatchers: ['.js']
    lexer: 'javascript'
    singleLineComment: ['//']

  JSON:
    nameMatchers: ['.json']
    lexer: 'json'
    singleLineComment: ['//']

  LaTeX:
    nameMatchers: ['.tex', '.latex', '.sty']
    lexer: 'tex'
    singleLineComment: ['%']

  Lua:
    nameMatchers: ['.lua']
    lexer: 'lua'
    singleLineComment: ['--']
    multiLineComment: [///^\s*\-\-+\[=*\[///, ///\s*\]=*\]///]

  Make:
    nameMatchers: ['Makefile']
    lexer: 'make'
    singleLineComment: ['#']

  'Objective-C':
    nameMatchers: ['.m', '.mm']
    lexer: 'objectivec'
    singleLineComment: ['//']

  Perl:
    nameMatchers: ['.pl', '.pm']
    lexer: 'perl'
    singleLineComment: ['#']

  PHP:
    nameMatchers: [/\.php\d?$/, '.fbp']
    lexer: 'php'
    singleLineComment: ['//']

  Python:
    nameMatchers: ['.py']
    lexer: 'python'
    singleLineComment: ['#']

  Ruby:
    nameMatchers: ['.rb', '.ru', '.gemspec']
    lexer: 'ruby'
    singleLineComment: ['#']

  # TODO: use Stylus lexer
  SCSS:
    nameMatchers: ['.scss', '.less', '.sass', '.styl']
    lexer: 'scss'
    singleLineComment: ['/*-']

  SQL:
    nameMatchers: ['.sql']
    lexer: 'sql'
    singleLineComment: ['--']

  XML:
    nameMatchers: ['.xml','.rdf']
    lexer: 'xml'
    singleLineComment: ['<!---']
    multiLineComment: [///^\s*\<\!\-\-+///, ///\s*\-+\>///]

  CMD:
    nameMatchers: ['.cmd', '.bat']
    lexer: 'dos'
    singleLineComment: ['@rem']

  HTML:
    nameMatchers: ['.html', '.htm']
    lexer: 'html'
    singleLineComment: ['<!---']
    multiLineComment: [///^\s*\<\!\-\-+///, ///\s*\-+\>///]
  