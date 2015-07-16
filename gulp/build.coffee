'use strict'
_ = require('underscore.string')
fs = require('fs')
path = require('path')
bowerDir = JSON.parse(fs.readFileSync('.bowerrc')).directory + path.sep

module.exports = (gulp, $, config) ->
  isProd = $.yargs.argv.stage == 'prod'
  # delete build directory
  gulp.task 'clean', (cb) ->
    $.del config.buildDir, cb
  # compile markup files and copy into build directory
  gulp.task 'markup', [ 'clean' ], ->
    gulp.src([
      config.appMarkupFiles
      '!' + config.appComponents
    ]).pipe gulp.dest(config.buildDir)
  # compile styles and copy into build directory
  gulp.task 'styles', [ 'clean' ], ->
    gulp.src([
      config.appStyleFiles
      '!' + config.appComponents
    ]).pipe($.plumber(errorHandler: (err) ->
      $.notify.onError(
        title: 'Error linting at ' + err.plugin
        subtitle: ' '
        message: err.message.replace(/\u001b\[.*?m/g, '')
        sound: ' ') err
      @emit 'end'
      return
    )).pipe($.less()).pipe($.autoprefixer()).pipe($.if(isProd, $.cssRebaseUrls())).pipe($.if(isProd, $.modifyCssUrls(modify: (url) ->
      # determine if url is using http, https, or data protocol
      # cssRebaseUrls rebases these URLs, too, so we need to fix that
      beginUrl = url.indexOf('http:')
      if beginUrl < 0
        beginUrl = url.indexOf('https:')
      if beginUrl < 0
        beginUrl = url.indexOf('data:')
      if beginUrl > -1
        return url.substring(beginUrl, url.length)
      # prepend all other urls
      '../' + url
    ))).pipe($.if(isProd, $.concat('app.css'))).pipe($.if(isProd, $.cssmin())).pipe($.if(isProd, $.rev())).pipe gulp.dest(config.buildCss)
  # compile scripts and copy into build directory
  gulp.task 'scripts', [
    'clean'
    'analyze'
    'markup'
  ], ->
    coffeeFilter = $.filter('**/*.coffee')
    htmlFilter = $.filter('**/*.html')
    jsFilter = $.filter('**/*.js')
    gulp.src([
      config.appScriptFiles
      config.buildDir + '**/*.html'
      '!' + config.appComponents
      '!**/*_test.*'
      '!**/index.html'
    ]).pipe($.sourcemaps.init()).pipe(coffeeFilter).pipe($.coffee()).pipe(coffeeFilter.restore()).pipe($.if(isProd, htmlFilter)).pipe($.if(isProd, $.ngHtml2js(
      moduleName: _.camelize(_.slugify(_.humanize(require('../package.json').name)))
      declareModule: false))).pipe($.if(isProd, htmlFilter.restore())).pipe(jsFilter).pipe($.if(isProd, $.angularFilesort())).pipe($.if(isProd, $.concat('app.js'))).pipe($.if(isProd, $.ngAnnotate())).pipe($.if(isProd, $.uglify())).pipe($.if(isProd, $.rev())).pipe($.addSrc($.mainBowerFiles(filter: /webcomponents/))).pipe($.sourcemaps.write('.')).pipe(gulp.dest(config.buildJs)).pipe jsFilter.restore()
  # inject custom CSS and JavaScript into index.html
  gulp.task 'inject', [
    'markup'
    'styles'
    'scripts'
  ], ->
    jsFilter = $.filter('**/*.js')
    gulp.src(config.buildDir + 'index.html').pipe($.inject(gulp.src([
      config.buildCss + '**/*'
      config.buildJs + '**/*'
      '!**/webcomponents.js'
    ]).pipe(jsFilter).pipe($.angularFilesort()).pipe(jsFilter.restore()),
      addRootSlash: false
      ignorePath: config.buildDir)).pipe($.inject(gulp.src([ config.buildJs + 'webcomponents.js' ]),
      starttag: '<!-- inject:head:{{ext}} -->'
      endtag: '<!-- endinject -->'
      addRootSlash: false
      ignorePath: config.buildDir)).pipe gulp.dest(config.buildDir)
  # copy bower components into build directory
  gulp.task 'bowerCopy', [ 'inject' ], ->
    cssFilter = $.filter('**/*.css')
    jsFilter = $.filter('**/*.js')
    gulp.src($.mainBowerFiles(), base: bowerDir).pipe(cssFilter).pipe($.if(isProd, $.modifyCssUrls(modify: (url, filePath) ->
      if url.indexOf('http') != 0 and url.indexOf('data:') != 0
        filePath = path.dirname(filePath) + path.sep
        filePath = filePath.substring(filePath.indexOf(bowerDir) + bowerDir.length, filePath.length)
      url = path.normalize(filePath + url)
      url = url.replace(/[/\\]/g, '/')
      url
    ))).pipe($.if(isProd, $.concat('vendor.css'))).pipe($.if(isProd, $.cssmin())).pipe($.if(isProd, $.rev())).pipe(gulp.dest(config.extDir)).pipe(cssFilter.restore()).pipe(jsFilter).pipe($.if(isProd, $.concat('vendor.js'))).pipe($.if(isProd, $.uglify(preserveComments: $.uglifySaveLicense))).pipe($.if(isProd, $.rev())).pipe(gulp.dest(config.extDir)).pipe jsFilter.restore()
  # inject bower components into index.html
  gulp.task 'bowerInject', [ 'bowerCopy' ], ->
    if isProd
      gulp.src(config.buildDir + 'index.html').pipe($.inject(gulp.src([
        config.extDir + 'vendor*.css'
        config.extDir + 'vendor*.js'
      ], read: false),
        starttag: '<!-- bower:{{ext}} -->'
        endtag: '<!-- endbower -->'
        addRootSlash: false
        ignorePath: config.buildDir)).pipe($.htmlmin(
        collapseWhitespace: true
        removeComments: true)).pipe gulp.dest(config.buildDir)
    else
      gulp.src(config.buildDir + 'index.html').pipe($.wiredep.stream(
        exclude: [ /webcomponents/ ]
        ignorePath: '../../' + bowerDir.replace(/\\/g, '/')
        fileTypes: html: replace:
          css: (filePath) ->
            '<link rel="stylesheet" href="' + config.extDir.replace(config.buildDir, '') + filePath + '">'
          js: (filePath) ->
            '<script src="' + config.extDir.replace(config.buildDir, '') + filePath + '"></script>'
      )).pipe gulp.dest(config.buildDir)
  # compile components and copy into build directory
  gulp.task 'components', [ 'bowerInject' ], ->
    polymerBowerAssetsToCopy = undefined
    scriptFilter = $.filter('**/*.coffee')
    styleFilter = $.filter('**/*.less')
    # List all Bower component assets that should be copied to the build
    # directory. The Bower directory is automatically prepended via the
    # map function.
    polymerBowerAssetsToCopy = [ 'polymer/polymer*.html' ].map((file) ->
      bowerDir + file
    )
    gulp.src(config.appComponents).pipe($.addSrc(polymerBowerAssetsToCopy, base: bowerDir)).pipe($.sourcemaps.init()).pipe(scriptFilter).pipe($.coffee()).pipe(scriptFilter.restore()).pipe(styleFilter).pipe($.less()).pipe(styleFilter.restore()).pipe($.sourcemaps.write('.')).pipe gulp.dest(config.buildComponents)
  # inject components
  gulp.task 'componentsInject', [ 'components' ], ->
    # List all Polymer and custom copmonents that should be injected
    # into index.html. The are injected in the order listed and the
    # components directory is automatically prepended via the
    # map function.
    polymerAssetsToInject = [ 'polymer/polymer.html' ].map((file) ->
      config.buildComponents + file
    )
    gulp.src(config.buildDir + 'index.html').pipe($.inject(gulp.src(polymerAssetsToInject),
      starttag: '<!-- inject:html -->'
      endtag: '<!-- endinject -->'
      addRootSlash: false
      ignorePath: config.buildDir)).pipe gulp.dest(config.buildDir)
  # copy Bower fonts and images into build directory
  gulp.task 'bowerAssets', [ 'clean' ], ->
    assetFilter = $.filter('**/*.{eot,otf,svg,ttf,woff,gif,jpg,jpeg,png}')
    gulp.src($.mainBowerFiles(), base: bowerDir).pipe(assetFilter).pipe(gulp.dest(config.extDir)).pipe assetFilter.restore()
  # copy custom fonts into build directory
  gulp.task 'fonts', [ 'clean' ], ->
    fontFilter = $.filter('**/*.{eot,otf,svg,ttf,woff}')
    gulp.src([ config.appFontFiles ]).pipe(fontFilter).pipe(gulp.dest(config.buildFonts)).pipe fontFilter.restore()
  # copy and optimize images into build directory
  gulp.task 'images', [ 'clean' ], ->
    gulp.src(config.appImageFiles).pipe($.if(isProd, $.imagemin())).pipe gulp.dest(config.buildImages)
  gulp.task 'copyTemplates', [ 'componentsInject' ], ->
    # always copy templates to testBuild directory
    stream = $.streamqueue(objectMode: true)
    stream.queue gulp.src([ config.buildDirectiveTemplateFiles ])
    stream.done().pipe gulp.dest(config.buildTestDirectiveTemplatesDir)
  gulp.task 'deleteTemplates', [ 'copyTemplates' ], (cb) ->
    # only delete templates in production
    # the templates are injected into the app during prod build
    if !isProd
      return cb()
    gulp.src([ config.buildDir + '**/*.html' ]).pipe(gulp.dest('tmp/' + config.buildDir)).on 'end', ->
      $.del [
        config.buildDir + '*'
        '!' + config.buildComponents
        '!' + config.buildCss
        '!' + config.buildFonts
        '!' + config.buildImages
        '!' + config.buildJs
        '!' + config.extDir
        '!' + config.buildDir + 'index.html'
      ], { mark: true }, cb
      return
    return
  gulp.task 'build', [
    'deleteTemplates'
    'bowerAssets'
    'images'
    'fonts'
  ]
  return
