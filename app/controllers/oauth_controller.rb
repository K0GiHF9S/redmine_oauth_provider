require 'oauth/controllers/provider_controller'

module AllowAuthorize
  def authorize
    params[:authorize] = '1' if params[:allow]
    super
  end
end

OAuth::Controllers::ProviderController.prepend(AllowAuthorize)

class OauthController < ApplicationController
  unloadable
  skip_before_action :check_if_login_required
  include OAuth::Controllers::ProviderController

  before_action :login_or_oauth_required, :only => [:user_info]

  def logged_in?
    User.current.logged?
  end

  def login_required
    raise Unauthorized unless User.current.logged?
  end

  def user_info
    user_hash = { :user => {} }
    user = User.find(session[:user_id])
    if user
      hash = user.attributes
      hash.delete(:hashed_password)
      hash.delete(:salt)
      hash.merge!(:mail => user.mail)
      user_hash = { :user => hash }
    end
    respond_to do |format|
      format.json { render :json => user_hash }
    end
  end

  def current_user
    User.find(session[:user_id])
  end

  def current_user=(user)
    start_user_session(user)
  end
end
