###global describe, beforeEach, it, browser, expect ###
'use strict'

buildConfigFile = require('findup-sync') 'build.config.js'
buildConfig = require buildConfigFile
RoasterPagePo = require './roaster.po'

describe 'Roaster page', ->
  roasterPage = undefined

  beforeEach ->
    roasterPage = new RoasterPagePo
    browser.driver.get buildConfig.host + ':' + buildConfig.port + '/#/roaster'

  it 'should say RoasterCtrl', ->
    expect(roasterPage.heading.getText()).toEqual 'roaster'
    expect(roasterPage.text.getText()).toEqual 'RoasterCtrl'
