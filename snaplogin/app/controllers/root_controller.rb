class RootController < ApplicationController
  def index
    token = cookies.signed[:snap_login]
    if token.present?
      @snap_login = SnapLogin.find_by_token(token)
    end
    if @snap_login.nil?
      @snap_login = SnapLogin.new
      @snap_login.token = UUIDTools::UUID.random_create.to_s
      @snap_login.save
      cookies.signed[:snap_login] = @snap_login.token
    end
    if @snap_login && @snap_login.email.present?
      @user_session = UserSession.create(User.find_by_email(@snap_login.email), true)
      @snap_login.destroy
      cookies.delete :snap_login
    else
      @user_session = UserSession.new
    end
  end
end
