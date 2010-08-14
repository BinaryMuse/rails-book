class UsersController < ApplicationController

  before_filter :require_signed_in,    :only => [:index, :edit, :update]
  before_filter :require_correct_user, :only => [:edit, :update]
  before_filter :require_signed_out,   :only => [:new, :create]
  before_filter :require_admin_user,   :only => [:destroy]

  def index
    @title = "All users"
    @users = User.paginate(:page => params[:page], :per_page => 20)
  end

  def show
    @user = User.find(params[:id])
    @micropost = Micropost.new if !@user.nil? and current_user == @user
    @microposts = @user.microposts.paginate(:page => params[:page], :per_page => 20)
    @title = @user.name
  end

  def new
    @title = "Sign up"
    @user = User.new
  end

  def create
    @user = User.new(params[:user])
    if @user.save
      sign_in @user
      flash[:success] = "Welcome to Fritter!"
      redirect_to @user
    else
      @title = "Sign up"
      @user.password = ""
      @user.password_confirmation = ""
      render 'new'
    end
  end

  def edit
    @title = "Edit user"
    render 'edit'
  end

  def update
    if @user.update_attributes(params[:user])
      flash[:success] = "Profile updated successfully"
      redirect_to @user
    else
      @title = "Edit user"
      render 'edit'
    end
  end

  def destroy
    user = User.find(params[:id])
    if user == current_user
      flash[:error] = "You cannot delete your own account"
    else
      user.destroy
      flash[:success] = "User destroyed"
    end
    redirect_to users_path
  end

end
