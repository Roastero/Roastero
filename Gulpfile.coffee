'use strict'
_ = require('lodash')
buildConfig = require('./build.config')
config = {}
gulp = require('gulp')
gulpFiles = require('require-dir')('./gulp')
path = require('path')
$ = undefined
key = undefined
$ = require('gulp-load-plugins')(pattern: [
  'browser-sync'
  'del'
  'gulp-*'
  'karma'
  'main-bower-files'
  'multi-glob'
  'plato'
  'run-sequence'
  'streamqueue'
  'uglify-save-license'
  'wiredep'
  'yargs'
])
_.merge config, buildConfig
config.appComponents = path.join(config.appDir, 'components/**/*')
config.appFiles = path.join(config.appDir, '**/*')
config.appFontFiles = path.join(config.appDir, 'fonts/**/*')
config.appImageFiles = path.join(config.appDir, 'images/**/*')
config.appMarkupFiles = path.join(config.appDir, '**/*.html')
config.appScriptFiles = path.join(config.appDir, '**/*.coffee')
config.appStyleFiles = path.join(config.appDir, '**/*.less')
config.buildDirectiveTemplateFiles = path.join(config.buildDir, '**/*directive.tpl.html')
config.buildJsFiles = path.join(config.buildJs, '**/*.js')
config.buildTestDirectiveTemplateFiles = path.join(config.buildTestDir, '**/*directive.tpl.html')
config.buildE2eTestsDir = path.join(config.buildTestDir, 'e2e')
config.buildE2eTests = path.join(config.buildE2eTestsDir, '**/*_test.js')
config.buildTestDirectiveTemplatesDir = path.join(config.buildTestDir, 'templates')
config.buildUnitTestsDir = path.join(config.buildTestDir, config.unitTestDir)
config.buildUnitTestFiles = path.join(config.buildUnitTestsDir, '**/*_test.js')
config.e2eFiles = path.join('e2e', '**/*.coffee')
config.unitTestFiles = path.join(config.unitTestDir, '**/*_test.coffee')
for key of gulpFiles
  gulpFiles[key] gulp, $, config
gulp.task 'dev', [ 'build' ], ->
  gulp.start 'browserSync'
  gulp.start 'watch'
  return
gulp.task 'default', [ 'dev' ]
