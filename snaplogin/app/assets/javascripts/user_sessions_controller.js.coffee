# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/


class QRAuth

  characters = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"

  _readChallengeFromPage = ->
    $('#full_url').val()
#    l = characters.length
#    r = new String
#    r = r + characters.charAt Math.floor Math.random() * l for [0..90]
#    r


  constructor:  ->
    @element    = $('#code')
    @url        = ko.observable location.href
    @challenge  = ko.observable _readChallengeFromPage()
    @lchallenge = $('#same_origin_url').val()
    @qrcode     = ko.observable null
    @testingCount = 0
    @init()


  getNewChallenge    : ->
    $.ajax
      url: @lchallenge
      method: 'delete'
    .done ->
      location.reload()
#    document.cookie = "username=; expires=Thu, 01 Jan 1970 00:00:00 GMT"
#    location.reload()

  refresh : ->
    @element.qrcode @challenge()

  regenerate : ->
    $ @element .empty()
    @getNewChallenge()

  checkForAuthenticated : ->
#    @testingCount += 1
#    if @testingCount >= 3
#      location.reload()
#      console.log 'reloaded'
    $.ajax
      url: @lchallenge
    .done (data) ->
      if data.email? and data.email.length > 0
        location.reload()



  init    : =>
    @refresh()
    setInterval(=>
      @checkForAuthenticated()
    , 1000)

window.QRAuth = QRAuth

$ ->
  $('#qrcode').each ->
    view = new QRAuth
    ko.applyBindings view, this