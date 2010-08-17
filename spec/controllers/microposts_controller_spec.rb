require 'spec_helper'

describe MicropostsController do
  render_views

  describe "access control" do
    it "should deny access to 'create'" do
      post :create
      response.should redirect_to signin_path
    end

    it "should deny access to 'destroy'" do
      delete :destroy, :id => 1
      response.should redirect_to signin_path
    end
  end

  describe "POST 'create'" do
    before :each do
      @user = test_sign_in(Factory(:user))
    end

    describe "failure" do
      before :each do
        @attr = { :content => "" }
      end

      it "should not create a micropost" do
        lambda do
          post :create, :micropost => @attr
        end.should_not change(Micropost, :count)
      end

      it "should render the home page" do
        post :create, :micropost => @attr
        response.should render_template 'pages/home'
      end
    end

    describe "success" do
      before :each do
        @attr = { :content => "Lorem ipsum" }
      end

      it "should create a micropost" do
        lambda do
          post :create, :micropost => @attr
        end.should change(Micropost, :count).by(1)
      end

      it "should redirect to the home page" do
        post :create, :micropost => @attr
        response.should redirect_to root_path
      end

      it "should have a flash message" do
        post :create, :micropost => @attr
        flash[:success].should =~ /created/i
      end
    end
  end

  describe "DELETE 'destroy'" do
    describe "for an unautorhized user" do
      before :each do
        @user = Factory(:user)
        wrong_user = Factory(:user, :email => Factory.next(:email))
        test_sign_in(wrong_user)
        @micropost = Factory(:micropost, :user => @user)
      end

      it "should deny access" do
        delete :destroy, :id => @micropost
        response.should redirect_to root_path
      end
    end

    describe "for an authorized user" do
      before :each do
        @user = test_sign_in(Factory(:user))
        @micropost = Factory(:micropost, :user => @user)
      end

      it "should destroy the micropost" do
        lambda do
          delete :destroy, :id => @micropost
        end.should change(Micropost, :count).by(-1)
      end
    end
  end

  describe "from_users_followed_by" do
    before :each do
      @other_user = Factory(:user, :email => Factory.next(:email))
      @third_user = Factory(:user, :email => Factory.next(:email))

      @user_post  = @user.microposts.create! :content => "foo"
      @other_post = @other_user.microposts.create! :content => "foo"
      @third_post = @third_user.microposts.create! :content => "foo"

      @user.follow! @other_user
    end

    it "should have a from_users_followed_by class method" do
      Micropost.should respond_to :from_users_followed_by
    end

    it "should include the followed user's posts" do
      Micropost.from_users_followed_by(@user).include?(@other_post).should be_true
    end

    it "should include the user's own posts" do
      Micropost.from_users_followed_by(@user).include?(@user_post).should be_true
    end

    it "should not include an unfollowed user's posts" do
      Micropost.from_users_followed_by(@user).include?(@third_post).should be_false
    end
  end
end