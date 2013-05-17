require('coffee-script')
var fs   = require('fs')
var path = require ('path')

module.exports = {
  PACKAGE_INFO: require('./lib/package_info'),
  CLI:          require('./lib/cli'),
  LANGUAGES:    require('./lib/languages'),
  Project:      require('./lib/project'),
  styles:       require('./lib/styles'),
}
