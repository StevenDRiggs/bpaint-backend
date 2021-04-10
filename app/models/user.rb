class User < ApplicationRecord
  has_secure_password
  
  has_one :avatar
  has_and_belongs_to_many :packages
  has_many :recipes
  has_many :colors

  validates :username, name: true, profanity_filter: true
  validates :password, password: true
end
