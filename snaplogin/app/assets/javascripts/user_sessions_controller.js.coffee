# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/


class QRAuth

  characters = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"

  _readChallengeFromPage = ->
#    $('#challenge').data
    l = characters.length
    r = new String
    r = r + characters.charAt Math.floor Math.random() * l for [0..90]
    r


  constructor:  ->
    @element      = $('#code')
    @url          = ko.observable location.href
    @challenge    = ko.observable null
    @qrcode       = ko.observable null
    @checkAuthURL = @url()+'/verify.json'
    @init()


  getNewChallenge    :  (callback) =>
    @challenge _readChallengeFromPage()
    callback [@url(), @challenge()]
    return

  refresh : (strArray) =>

    $ @element.qrcode strArray.join()

  regenerate : ->
    $ @element .empty()
    @getNewChallenge @refresh

  checkForAuthenticated : (u)   ->
#    @testingCount += 1
#    if @testingCount >= 3
#      location.reload()
#      console.log 'reloaded'
    $.ajax
      url: u
    .done (data) ->
      if data.authenticated
        location.reload()



  init    : ->
    @getNewChallenge @refresh
    setInterval @checkForAuthenticated @checkAuthURL, 1000

window.QRAuth = QRAuth

$ ->
  $('#qrcode').each ->
    view = new QRAuth
    ko.applyBindings view, this