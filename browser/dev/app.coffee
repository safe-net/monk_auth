class QRAuth
    
    characters = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
    
    _randomText = ->
        l = characters.length
        r = new String
        r = r + characters.charAt Math.floor Math.random() * l for [0..20]
        r
        
            
    constructor:  ->
        @element    = $('#code')
        @url        = ko.observable _randomText()
        @challenge  = ko.observable null
        @qrcode     = ko.observable null
        @init()
        
        
    getNewChallenge    :  (callback) =>
#        host = location.href
#        $.onload
#            @qrcode response.text
#        $.get
#            data:
#                authcode
#            url: host
        @challenge _randomText()
        callback [@url(), @challenge()]
        return
        
    refresh : (strArray) =>
            
        $ @element.qrcode strArray.join()
        
    regenerate : ->
        $ @element .empty()
        @getNewChallenge @refresh
        
    checkStillAuthenticated : ->
        return
        
    init    : =>
        @getNewChallenge @refresh
        @checkStillAuthenticated()
        
window.QRAuth = QRAuth

$ ->
    $('#qrcode').each ->
        view = new QRAuth
        ko.applyBindings view, this