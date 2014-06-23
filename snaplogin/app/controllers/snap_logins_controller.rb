class SnapLoginsController < ApplicationController
  skip_before_action :verify_authenticity_token

  def update
    @snap_login = SnapLogin.find_by_token(params[:id])
    @snap_login.update(params.permit(:email))
    # redirect_to root_index_path
    render json: {ok: 'yeah'}
  end

  def show
    @snap_login = SnapLogin.find_by_token(params[:id])
    render json: {token: @snap_login.token, email: @snap_login.email}
  end


  def destroy
    @snap_login = SnapLogin.find_by_token(params[:id])
    @snap_login.destroy
    render json: {ok: 'yeah'}
  end
end
