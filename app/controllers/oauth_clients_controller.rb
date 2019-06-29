class OauthClientsController < ApplicationController
  unloadable

  before_action :get_user
  before_action :get_client_application, :only => [:show, :edit, :update, :destroy]

  def index
    @client_applications = @user.client_applications
    @tokens = @user.tokens.where('oauth_tokens.invalidated_at is null and oauth_tokens.authorized_at is not null')
  end

  def new
    @client_application = ClientApplication.new
  end

  def create
    @client_application = @user.client_applications.build(client_application_params)
    if @client_application.save
      flash[:notice] = l("Registered the information successfully")
      redirect_to :action => "show", :id => @client_application.id
    else
      render :action => "new"
    end
  end

  def show
  end

  def edit
  end

  def update
    if @client_application.update_attributes(client_application_params)
      flash[:notice] = l("Updated the client information successfully")
      redirect_to :action => "show", :id => @client_application.id
    else
      render :action => "edit"
    end
  end

  def destroy
    @client_application.destroy
    flash[:notice] = l("Destroyed the client application registration")
    redirect_to :action => "index"
  end

  private

  def get_user
    render_403 unless User.current.logged?

    if params[:user_id] && params[:user_id] != User.current.id.to_s
      if User.current.admin?
        @user = User.find(params[:user_id])
      else
        render_403
      end
    else
      @user = User.current
    end
  end

  def get_client_application
    unless @client_application = @user.client_applications.find(params[:id])
      flash.now[:error] = l("Wrong application id")
      raise ActiveRecord::RecordNotFound
    end
  end

  def client_application_params
    params.require(:client_application).permit(:name, :url, :callback_url, :support_url)
  end
end
