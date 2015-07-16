'use strict'

module.exports = (gulp, $, config) ->
  gulp.task 'browserSync', ->
    $.browserSync
      host: config.host
      open: 'external'
      port: config.port
      server: baseDir: config.buildDir
    return
  gulp.task 'watch', ->
    $.browserSync.reload()
    gulp.watch [ config.unitTestFiles ], [ 'unitTest' ]
    gulp.watch [
      config.appFiles
      '!' + config.unitTestFiles
    ], [
      'build'
      $.browserSync.reload
    ]
    return
  return
