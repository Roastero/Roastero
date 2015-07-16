'use strict'

module.exports = (gulp, $, config) ->
  # lint source code
  gulp.task 'lint', ->
    gulp.src([
      config.appScriptFiles
      config.e2eFiles
      config.unitTestFiles
    ]).pipe($.plumber(errorHandler: (err) ->
      $.notify.onError(
        title: 'Error linting at ' + err.plugin
        subtitle: ' '
        message: err.message.replace(/\u001b\[.*?m/g, '')
        sound: ' ') err
      @emit 'end'
      return
    )).pipe($.coffeelint()).pipe($.coffeelint.reporter()).pipe $.coffeelint.reporter('fail')
  # run plato anaylysis on JavaScript (ES5) files
  gulp.task 'staticAnalysis', (done) ->
    $.multiGlob.glob [
      config.appScriptFiles
      config.e2eFiles
      config.unitTestFiles
    ], (err, matches) ->
      if err
        throw new Error('Couldn\'t find files.')
      # only inspect JS (ES5) files
      matches = matches.filter((file) ->
        file.match /.*[.]js/
      )
      if matches.length > 0
        $.plato.inspect matches, './report', {}, ->
          done()
          return
      else
        done()
      return
    return
  gulp.task 'analyze', [
    'lint'
    'staticAnalysis'
  ]
  return
