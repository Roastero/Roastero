'use strict'
buildConfig = require('./build.config.js')
preprocessors = {}
buildTestDir = undefined
templateDir = undefined
jsDir = undefined
buildTestDir = buildConfig.buildTestDir
# add slash if missing to properly strip prefix from directive templates
if buildTestDir[buildTestDir.length - 1] != '/'
  buildTestDir = buildTestDir + '/'
templateDir = buildTestDir + 'templates/'
jsDir = buildConfig.buildJs
# add slash if missing to properly strip prefix from directive templates
if jsDir[jsDir.length - 1] != '/'
  jsDir = jsDir + '/'
preprocessors[jsDir + '**/*.js'] = [ 'coverage' ]
preprocessors[templateDir + '**/*-directive.tpl.html'] = [ 'ng-html2js' ]
module.exports =
  browsers: [ 'PhantomJS' ]
  frameworks: [
    'jasmine'
    'sinon'
  ]
  reporters: [
    'failed'
    'coverage'
  ]
  preprocessors: preprocessors
  ngHtml2JsPreprocessor: stripPrefix: templateDir
  singleRun: true
