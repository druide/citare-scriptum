module.exports = function(hljs) {
  var TYPENAME = {
    begin: '[\\w/]+\\s+', end: '[\\w]+',
    excludeEnd: true,
    endsWithParent: true,
    className: 'attribute'
  };
  var SNIPPET =[
    {
      begin: '^\\s*\\w+', end: '\\(',
      excludeEnd: true,
      className: 'title'
    },
    {
      end: '\\)',
      excludeEnd: true,
      contains: [
        {
          end: ',',
          endsWithParent: true,
          contains: [
            {
              begin: '\\[', end: '\\]',
              endsWithParent: true,
              className: 'optional',
              contains: [
                TYPENAME
              ]
            },
            TYPENAME,
            {
              begin: ':\\s*', end: '[\\w]+',
              excludeBegin: true,
              endsWithParent: true,
              className: 'attribute'
            }
          ]
        }
      ]
    }
  ];

  return {
    contains: SNIPPET
  };
};