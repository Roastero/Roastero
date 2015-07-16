###global describe, beforeEach, it, browser, expect ###
'use strict'

buildConfigFile = require('findup-sync') 'build.config.js'
buildConfig = require buildConfigFile
HomePagePo = require './home.po'

describe 'Home page', ->
  homePage = undefined

  beforeEach ->
    homePage = new HomePagePo
    browser.driver.get buildConfig.host + ':' + buildConfig.port + '/#/home'

  it 'should say HomeCtrl', ->
    expect(homePage.heading.getText()).toEqual 'home'
    expect(homePage.text.getText()).toEqual 'HomeCtrl'
