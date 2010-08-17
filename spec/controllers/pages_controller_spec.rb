require 'spec_helper'

describe PagesController do
  render_views

  before(:each) do
    @base_title = 'Fritter'
  end

  describe "GET 'home'" do
    it "should be successful" do
      get 'home'
      response.should be_success
    end

    it "should have the right title" do
      get 'home'
      response.should have_selector('title', :content => @base_title + ' | Home')
    end

    describe "for signed in users" do
      before :each do
        @user = Factory(:user)
        test_sign_in(@user)
      end

      describe "microposts display" do
        before :each do
          @mp1 = Factory(:micropost, :user => @user, :content => "Foo bar")
        end

        it "should show a list of the users microposts" do
          mp2 = Factory(:micropost, :user => @user, :content => "Baz quix")
          get 'home'
          response.should have_selector "span.content", :content => @mp1.content
          response.should have_selector "span.content", :content => mp2.content
        end

        it "should show a count of the users microposts with correct singular form" do
          get 'home'
          response.should have_selector "span.microposts", :content => "1 Freet"
        end

        it "should show a count of the users microposts with correct plural form" do
          mp2 = Factory(:micropost, :user => @user, :content => "Baz quix")
          get 'home'
          response.should have_selector "span.microposts", :content => "2 Freets"
        end
      end

      describe "follower/followed display" do
        before :each do
          other_user = Factory(:user, :email => Factory.next(:email))
          other_user.follow! @user
        end

        it "should have the right count" do
          get :home
          response.should have_selector "a", :href => following_user_path(@user),
                                             :content => "0"
          response.should have_selector "a", :href => followers_user_path(@user),
                                             :content => "1"
        end
      end
    end
  end

  describe "GET 'contact'" do
    it "should be successful" do
      get 'contact'
      response.should be_success
    end

    it "should have the right title" do
      get 'contact'
      response.should have_selector('title',
        :content => @base_title + ' | Contact')
    end
  end

  describe "GET 'about'" do
    it "should be successful" do
      get 'about'
      response.should be_success
    end

    it "should have the right title" do
      get 'about'
      response.should have_selector('title',
        :content => @base_title + ' | About')
    end
  end

  describe "GET 'help'" do
    it "should be successful" do
      get 'help'
      response.should be_success
    end

    it "should have the right title" do
      get 'help'
      response.should have_selector('title',
        :content => @base_title + ' | Help')
    end
  end

end
