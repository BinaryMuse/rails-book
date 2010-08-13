module SessionsHelper
  def sign_in(user)
    cookies.permanent.signed[:remember_token] = [user.id, user.salt]
    current_user = user
  end

  def signed_in?
    !current_user.nil?
  end

  def sign_out
    cookies.delete(:remember_token)
    self.current_user = nil
  end

  def require_signed_out
    redirect_to current_user if signed_in?
  end

  def require_signed_in
    unless signed_in?
      store_location
      redirect_to signin_path, :notice => "Please sign in to access this page"
    end
  end

  def require_correct_user
    @user = User.find(params[:id])
    redirect_to root_path unless (@user == current_user or current_user.admin?)
  end

  def require_admin_user
    # Returning as just redirecting doesn't seem to end function
    return redirect_to signin_path unless signed_in?
    return redirect_to root_path unless current_user.admin?
  end

  def store_location
    session[:return_to] = request.fullpath
  end

  def clear_return_to
    session[:return_to] = nil
  end

  def redirect_back_or_to(default)
    redirect_to(session[:return_to] || default)
    clear_return_to
  end

  def current_user=(user)
    @current_user = user
  end

  def current_user
    @current_user ||= user_from_remember_token
  end

  private

    def user_from_remember_token
      User.authenticate_with_salt(*remember_token)
    end

    def remember_token
      cookies.signed[:remember_token] || [nil, nil]
    end
end
