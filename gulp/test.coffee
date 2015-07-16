'use strict'
karmaConf = require('../karma.config')
# karmaConf.files get populated in karmaFiles
karmaConf.files = [ 'node_modules/karma-babel-preprocessor/node_modules/babel-core/browser-polyfill.js' ]

module.exports = (gulp, $, config) ->
  gulp.task 'clean:test', (cb) ->
    $.del config.buildTestDir, cb
  gulp.task 'buildTests', [
    'lint'
    'clean:test'
  ], ->
    gulp.src([ config.unitTestFiles ]).pipe($.coffee()).pipe gulp.dest(config.buildUnitTestsDir)
  # inject scripts in karma.config.js
  gulp.task 'karmaFiles', [
    'build'
    'buildTests'
  ], ->
    stream = $.streamqueue(objectMode: true)
    # add bower javascript
    stream.queue gulp.src($.wiredep(
      devDependencies: true
      exclude: [
        /polymer/
        /webcomponents/
      ]).js)
    # add application templates
    stream.queue gulp.src([ config.buildTestDirectiveTemplateFiles ])
    # add application javascript
    stream.queue gulp.src([
      config.buildJsFiles
      '!**/webcomponents.js'
      '!**/*_test.*'
    ]).pipe($.angularFilesort())
    # add unit tests
    stream.queue gulp.src([ config.buildUnitTestFiles ])
    stream.done().on 'data', (file) ->
      karmaConf.files.push file.path
      return
  # run unit tests
  gulp.task 'unitTest', [
    'lint'
    'karmaFiles'
  ], (done) ->
    $.karma.server.start karmaConf, ->
      done()
      return
    return
  gulp.task 'build:e2eTest', ->
    gulp.src([ config.e2eFiles ]).pipe($.coffee()).pipe gulp.dest(config.buildE2eTestsDir)
  # run e2e tests - SERVER MUST BE RUNNING FIRST
  gulp.task 'e2eTest', [
    'lint'
    'build:e2eTest'
  ], ->
    gulp.src(config.buildE2eTests).pipe($.protractor.protractor(configFile: 'protractor.config.coffee')).on 'error', (e) ->
      console.log e
      return
  # jscs:disable requireCamelCaseOrUpperCaseIdentifiers

  ### jshint -W106 ###

  gulp.task 'webdriverUpdate', $.protractor.webdriver_update

  ### jshint +W106 ###

  # jscs:enable requireCamelCaseOrUpperCaseIdentifiers
  return
