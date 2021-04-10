class User < ApplicationRecord
  has_secure_password
  
  has_one :avatar
  has_and_belongs_to_many :packages
  has_many :recipes
  has_many :colors

  validates :username, name: true, profanity_filter: true
  validates :email, presence: true, email: true
  validates :password, password: true

  def self.find_by_username_or_email(username_or_email)
    user = self.find_by(username: username_or_email)

    unless user
      user = self.find_by(email: username_or_email)
    end

    user
  end
end
