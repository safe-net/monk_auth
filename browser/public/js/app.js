var QRAuth,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

QRAuth = (function() {
  var characters, _randomText;

  characters = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";

  _randomText = function() {
    var l, r, _i;
    l = characters.length;
    r = new String;
    for (_i = 0; _i <= 20; _i++) {
      r = r + characters.charAt(Math.floor(Math.random() * l));
    }
    return r;
  };

  function QRAuth() {
    this.init = __bind(this.init, this);
    this.refresh = __bind(this.refresh, this);
    this.getNewChallenge = __bind(this.getNewChallenge, this);
    this.element = $('#code');
    this.url = ko.observable(_randomText());
    this.challenge = ko.observable(null);
    this.qrcode = ko.observable(null);
    this.init();
  }

  QRAuth.prototype.getNewChallenge = function(callback) {
    this.challenge(_randomText());
    callback([this.url(), this.challenge()]);
  };

  QRAuth.prototype.refresh = function(strArray) {
    return $(this.element.qrcode(strArray.join()));
  };

  QRAuth.prototype.regenerate = function() {
    $(this.element.empty());
    return this.getNewChallenge(this.refresh);
  };

  QRAuth.prototype.checkStillAuthenticated = function() {};

  QRAuth.prototype.init = function() {
    this.getNewChallenge(this.refresh);
    return this.checkStillAuthenticated();
  };

  return QRAuth;

})();

window.QRAuth = QRAuth;

$(function() {
  return $('#qrcode').each(function() {
    var view;
    view = new QRAuth;
    return ko.applyBindings(view, this);
  });
});
