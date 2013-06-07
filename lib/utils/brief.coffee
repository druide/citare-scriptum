#
#  # Brief syntax highlighter
#  Highlights `brief` function specification in the following format:
#
#  ```
#  functionName(Type argument1, Type1/Type2 argument2, Type optionalArgument1?): Type
#  ```
#
#  ```
#  functionName(Type argument1, Type1/Type2 argument2, [Type optionalArgument1]): Type
#  ```
#
#  Optional arguments are marked by the `?` at the end, or are surrounded in square braces `[...]`.  
#  Possible argument types are delimited by slash `/`.  
#
module.exports = (hljs) ->
  TYPENAME =
    begin: "[\\w/]+\\s+"
    end: "[\\w]+"
    excludeEnd: true
    endsWithParent: true
    className: "attribute"

  SNIPPET = [
    begin: "^\\s*\\w+"
    end: "\\("
    excludeEnd: true
    className: "title"
  ,
    end: "\\)"
    excludeEnd: true
    contains: [
      begin: "\\s*"
      end: ","
      excludeBegin: true
      endsWithParent: true
      contains: [
        begin: "\\["
        end: "\\]"
        endsWithParent: true
        className: "optional"
        contains: [TYPENAME]
      ,
        begin: "[\\w/\\s]+\\?+"
        endsWithParent: true
        returnBegin: true
        className: "optional"
        contains: [TYPENAME]
      , TYPENAME,
        begin: ":\\s*"
        end: "[\\w]+"
        excludeBegin: true
        endsWithParent: true
        className: "attribute"
      ]
    ]
  ]
  contains: SNIPPET
