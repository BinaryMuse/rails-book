class SessionsController < ApplicationController
  before_filter :require_signed_out, :except => [:destroy]

  def new
    @title = "Sign in"
  end

  def create
    user = User.authenticate params[:session][:email], params[:session][:password]
    if user.nil?
      flash.now[:error] = "The credentials you provided were invalid."
      @title = "Sign in"
      render 'new'
    else
      sign_in user
      redirect_to user
    end
  end

  def destroy
    sign_out
    redirect_to root_path
  end
end
