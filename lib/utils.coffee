# Miscellaneous code fragments reside here.
#
# TODO: These should be migrated into `lib/utils`.

childProcess = require 'child_process'
path         = require 'path'

_        = require 'underscore'
marked   = require 'marked'

CompatibilityHelpers = require './utils/compatibility_helpers'
LANGUAGES            = require './languages'
Logger               = require './utils/logger'
hljs = require('highlight.js')

module.exports = Utils =
  # Escape regular expression characters in a string
  #
  # Code from http://zetafleet.com/ via http://simonwillison.net/2006/Jan/20/escape/
  regexpEscape: (string) ->
    string.replace(/[-[\]{}()*+?.,\\^$|#\s]/g, '\\$&')

  # Detect and return the language that a given file is written in.
  #
  # The language is also annotated with a name property, matching the laguages key in LANGUAGES.
  getLanguage: (filePath) ->
    unless @_languageDetectionCache?
      @_languageDetectionCache = []

      for name, language of LANGUAGES
        language.name = name

        for matcher in language.nameMatchers
          # If the matcher is a string, we assume that it's a file extension.  Stick it in a regex:
          matcher = ///#{@regexpEscape matcher}$/// if _.isString matcher

          @_languageDetectionCache.push [matcher, language]

    baseName = path.basename filePath

    for pair in @_languageDetectionCache
      return pair[1] if baseName.match pair[0]

  # Map a list of file paths to relative target paths by stripping prefixes off of them.
  mapFiles: (resolveRoot, files, stripPrefixes) ->
    # Ensure that we're dealing with absolute paths across the board
    files = files.map (f) -> path.resolve resolveRoot, f
    # And that the strip prefixes all end with a /, to avoid a target path being absolute.
    stripPrefixes = stripPrefixes.map (p) -> path.join( "#{path.resolve resolveRoot, p}#{CompatibilityHelpers.pathSep}" )

    # Prefixes are stripped in order of most specific to least (# of directories deep)
    prefixes = stripPrefixes.sort (a,b) => @pathDepth(b) - @pathDepth(a)

    result = {}

    for absPath in files
      file = absPath

      for stripPath in stripPrefixes
        file = file[stripPath.length..] if file[0...stripPath.length] == stripPath

      # We also strip the extension under the assumption that the consumer of this path map is going
      # to substitute in their own.  Plus, if they care about the extension, they can get it from
      # the keys of the map.
      result[absPath] = if not path.extname(file) then file else file[0...-path.extname(file).length]

    result

  # Attempt to guess strip prefixes for a given set of arguments.
  guessStripPrefixes: (args) ->
    result = []
    for arg in args
      # Most globs look something like dir/**/*.ext, so strip up to the leading *
      arg = arg.replace /\*.*$/, ''

      result.push arg if arg.slice(-1) == CompatibilityHelpers.pathSep

    # For now, we try to avoid ambiguous situations by guessing the FIRST directory given.  The
    # assumption is that you don't want merged paths, but probably did specify the most important
    # source directory first.
    result = _(result).uniq()[...1]

  # How many directories deep is a given path?
  pathDepth: (path) ->
    path.split(/[\/\\]/).length

  # Split source code into segments (comment + code pairs)
  splitSource: (data, language, options={}) ->
    lines = data.split /\r?\n/

    # Always strip shebangs - but don't shift it off the array to avoid the perf hit of walking the
    # array to update indices.
    lines[0] = '' if lines[0][0..1] == '#!'

    # Special case: If the language is comments-only, we can skip syntax highlight
    return [new @Segment [], lines] if language.commentsOnly

    segments = []
    currSegment = new @Segment

    # Enforced whitespace after the comment token
    whitespaceMatch = if options.requireWhitespaceAfterToken then '\\s' else '\\s?'

    singleLineMatcher = ///^\s*(#{language.singleLineComment.join('|')})#{whitespaceMatch}(.*)$///
    singleEmptyLineMatcher = ///^\s*(#{language.singleLineComment.join('|')})(\s*)$///
    multiLineMatcher1 = ///^\s*/\*+///
    multiLineMatcher2 = ///\*+/\s*///
    if language.multiLineComment?
      multiLineMatcher1 = language.multiLineComment[0]
      if language.multiLineComment[1]?
        multiLineMatcher2 = language.multiLineComment[1]
      else
        multiLineMatcher2 = null
    incomment = false

    pushComment = (line) =>
      if currSegment.code.length > 0
        segments.push currSegment
        currSegment = new @Segment
      currSegment.comments.push line

    pushCode = (line) =>
      if !options.commentsOnly
        currSegment.code.push line
      else
        currSegment.code.push ''

    whiteSpace = (n) ->
      s = ""
      for i in [1 .. n]
        s += " "
      s

    for line in lines
      # Match that line to the language's single line comment syntax.
      #
      # However, we treat all comments beginning with } as inline code commentary.
      match = line.match singleLineMatcher
      match2 = line.match multiLineMatcher1
      if multiLineMatcher2?
        match3 = line.match multiLineMatcher2
      else
        if incomment
          match3 = match2
          match2 = null
        else
          match3 = null
      emptyMatch = line.match singleEmptyLineMatcher

      #} For example, this comment should be treated as part of our code.
      if !incomment and (match? and match[2]?[0] != '}' or emptyMatch?)
        if match?
          pushComment match[2]
        else
          pushComment ""
      else
        if match2? and line.replace(multiLineMatcher1, "")[0] != '}'
          incomment = true
          pushComment ""
          if match3?
            incomment = false
            pos1 = line.indexOf match2[0]
            pos2 = line.indexOf match3[0]
            pushComment line.substring(pos1 + match2[0].length, pos2)
            pushCode line.substring(pos2 + match3[0].length)
          else
            pushComment line.replace(match2[0], whiteSpace(match2[0].length - 1))
        else
          if match3?
            if !incomment
              pushCode line
            else
              pos = line.indexOf match3[0]
              pushComment line.substring(0, pos)
              pushCode line.substring(pos + match3[0].length + 1)
            incomment = false
          else
            if incomment
              pushComment line
            else
              # custom delimiter in coffescript source
              if line.match(/^[#]{4,}/)
                pushComment ""
              pushCode line

    segments.push currSegment
    if options.commentsOnly
      currSegment = new @Segment
      for segment in segments
        @trimLeftSpace segment
        currSegment.comments.push(segment.comments.join('\n'))
      segments = [currSegment]
    segments

  # Just a convenient prototype for building segments
  Segment: class Segment
    constructor: (code=[], comments=[]) ->
      @code     = code
      @comments = comments

  unescape: (value) ->
    value.replace(/&amp;/gm, '&').replace(/&lt;/gm, '<').replace(/&gt;/gm, '>')

  # sort out the smallest amount of space prefixing each line.
  trimLeftSpace: (segment) ->
    # sort out the smallest amount of space prefixing each line.
    spaces = 1000
    for line, i in segment.comments
      if line.trim().length > 0
        curspaces = /^(\s*)(.*)/.exec(line)[1].length
        if curspaces < spaces
          spaces = curspaces
    # now remove spaces from each line above.
    for line, i in segment.comments
      segment.comments[i] = line.slice(spaces)
    # handle "*" started block comments
    if segment.comments.length > 1
      isAsterixComment = true
      for line, i in segment.comments
        if i == 0 and line.length != 0
          isAsterixComment = false
          break
        else if i == 1 and !(line.length == 0 or line[0] == " ")
          isAsterixComment = false
          break
        else
          if line.trim().length != 0 and line[0] != "*"
            isAsterixComment = false
            break
      if isAsterixComment
        for line, i in segment.comments
          segment.comments[i] = line.substring(1)
    segment

  # Annotate an array of segments by running their code through [highlight.js](https://github.com/isagalaev/highlight.js).
  highlightCode: (segments, language, callback) ->
    # Don't bother spawning highlight.js if we have nothing to highlight
    numCodeLines = segments.reduce ( (c,s) -> c + s.code.length ), 0
    if numCodeLines == 0
      for segment in segments
        segment.highlightedCode = ''
      return callback()

    for segment, i in segments
      segmentCode = segment.code.join '\n'
      segment.highlightedCode = hljs.highlight(language.lexer, segmentCode).value

    return callback()

  # Annotate an array of segments by running their comments through
  # [marked](https://github.com/chjj/marked).
  markdownComments: (segments, project, callback) ->
    try
      tocHeaders = []

      for segment, segmentIndex in segments

        @trimLeftSpace segment

        # put this back together.
        markdown = marked segment.comments.join '\n'
        headers  = []

        # showdown generates header ids by lowercasing & dropping non-word characters.  We'd like
        # something a bit more readable.
        markdown = @gsub markdown, /<h(\d)>([^<]+)<\/h\d>/g, (match) =>
          header =
            level: parseInt match[1]
            title: match[2].replace ///#\{///g, '\\0x23{' # escape coffescript "#{}" interpolation
            slug:  @slugifyTitle match[2]

          header.isFileHeader = true if header.level == 1 && segmentIndex == 0 && match.index == 0

          headers.push header
          tocHeaders.push header

          """<h#{header.level}><a name="#{header.slug}" class="anchor" href="##{header.slug}"><span></span></a>#{header.title}</h#{header.level}>"""

        # temporary replace auto-links inside code blocks
        markdown = @gsub markdown, ///<code.*?>[\w\W]+?</code>///g, (match) ->
          match[0].replace(///{{TOC}}///g, "{{TOC__}}").replace(///\[///g, "{{_{{").replace(///\]///g, "}}_}}")

        # find and process auto-link nodes
        markdown = @gsub markdown, /\[[^\]]+\]/g, (match) ->
          text = match[0]
          "<span class=\"autolink\">#{text}</span>"

        # We attach the rendered markdown to the comment
        segment.markdownedComments = markdown
        # As well as the extracted headers to aid in outline building.
        segment.headers = headers

      # make TOC
      skipFirstHeader = false
      headerProcessed = false
      for segment, segmentIndex in segments
        if not headerProcessed
          tocPos = segment.markdownedComments.indexOf("{{TOC}}")
          headerPos = segment.markdownedComments.indexOf('class="anchor"')
          if tocPos != -1 or headerPos != -1
            headerProcessed = true
            if tocPos == -1
              skipFirstHeader = true
            else if headerPos == -1
              skipFirstHeader = false
            else
              skipFirstHeader = tocPos > headerPos
        # search for {{TOC}} tag
        segment.markdownedComments = @gsub segment.markdownedComments, ///{{TOC}}///g, (match) =>
          text = ""
          if tocHeaders.length
            text = "<div class=\"toc\">"
            for header, i in tocHeaders
              # always skip first header, usually it is top level header, and TOC is placed after it
              if i == 0 and skipFirstHeader
                continue
              text += @repeat(header.level) + "<a href=\"##{header.slug}\">#{header.title}</a><br/>"
            text = text + "</div>"
          headerProcessed = true
          text

      # revert temporary replaced code text
      for segment, segmentIndex in segments
        segment.markdownedComments = @gsub segment.markdownedComments, ///<code.*?>[\w\W]+?</code>///g, (match) ->
          match[0].replace(///{{TOC__}}///g, "{{TOC}}").replace(///{{_{{///g, "[").replace(///}}_}}///g, "]")

    catch error
      return callback error

    callback()

  # add *count* whitespaces
  repeat: (count) ->
    text = ""
    for i in [1..count-1]
      text += "&nbsp;&nbsp;&nbsp;&nbsp;"
    text

  # Sometimes you just don't want any of them hanging around.
  trimBlankLines: (string) ->
    if not string
      return ""
    string.replace(/^[\r\n]+/, '').replace(/[\r\n]+$/, '')

  # Given a title, convert it into a URL-friendly slug.
  slugifyTitle: (string) ->
    string.split(/[\s\-\_]+/).map( (s) -> s.replace(/[^\w]/g, '').toLowerCase() ).join '-'

  # replacer is a function that is given the match object, and returns the string to replace with.
  gsub: (string, matcher, replacer) ->
    throw new Error 'You must pass a global RegExp to gsub!' unless matcher.global?

    result = ''
    matcher.lastIndex = 0
    furthestIndex = 0

    while (match = matcher.exec string) != null
      result += string[furthestIndex...match.index] + replacer match

      furthestIndex = matcher.lastIndex

    result + string[furthestIndex...]
