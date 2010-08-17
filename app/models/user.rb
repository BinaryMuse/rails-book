# == Schema Information
# Schema version: 20100813183033
#
# Table name: users
#
#  id                 :integer         not null, primary key
#  name               :string(255)
#  email              :string(255)
#  created_at         :datetime
#  updated_at         :datetime
#  encrypted_password :string(255)
#  salt               :string(255)
#  admin              :boolean
#

class User < ActiveRecord::Base
  attr_accessor   :password
  attr_accessible :name, :email, :password, :password_confirmation

  has_many :microposts,            :dependent   => :destroy
  has_many :relationships,         :foreign_key => "follower_id",
                                   :dependent   => :destroy
  has_many :following,             :through     => :relationships,
                                   :source      => :followed
  has_many :reverse_relationships, :foreign_key => "followed_id",
                                   :class_name  => "Relationship",
                                   :dependent   => :destroy
  has_many :followers,             :through     => :reverse_relationships

  before_save :downcase_email, :encrypt_password

  email_regex = /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z0-9]+)\Z/i

  validates :name,     :presence     => true,
                       :length       => { :maximum => 50 }
  validates :email,    :presence     => true,
                       :format       => { :with => email_regex },
                       :uniqueness   => { :case_sensitive => false }
  validates :password, :presence     => true,
                       :confirmation => true,
                       :length       => { :within => 6..40 }

  def has_password?(submitted_password)
    encrypted_password == encrypt(submitted_password)
  end

  def self.authenticate(email, submitted_password)
    user = find_by_email email
    user && user.has_password?(submitted_password) ? user : nil
  end

  def self.authenticate_with_salt(id, cookie_salt)
    user = find_by_id(id)
    (user && user.salt == cookie_salt) ? user : nil
  end

  def feed
    ###Micropost.where("user_id = ?", id)
    Micropost.from_users_followed_by(self)
  end

  def following?(followed)
    relationships.find_by_followed_id followed
  end

  def follow!(followed)
    relationships.create! :followed_id => followed.id unless self.following? followed
  end

  def unfollow!(followed)
    relationships.find_by_followed_id(followed).destroy if self.following? followed
  end

  private

    def downcase_email
      self.email.downcase!
    end

    def encrypt_password
      self.salt = make_salt if new_record?
      self.encrypted_password = encrypt password
    end

    def encrypt(string)
      secure_hash("#{salt}--#{string}")
    end

    def make_salt
      secure_hash("#{Time.now.utc}--#{password}")
    end

    def secure_hash(string)
      Digest::SHA2.hexdigest string
    end

end
