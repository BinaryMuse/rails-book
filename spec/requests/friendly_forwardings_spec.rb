require 'spec_helper'

describe "FriendlyForwardings" do
  it "should forward to the requested page after sign in" do
    user = Factory(:user)
    visit edit_user_path(user)
    # Redirected to the login page
    fill_in :email, :with => user.email
    fill_in :password, :with => user.password
    click_button
    # Now we want to be at edit_user_path(user) again
    response.should render_template 'users/edit'
  end
end
