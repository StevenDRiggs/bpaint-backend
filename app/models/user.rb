class User < ApplicationRecord
  has_secure_password
  
  has_one :avatar
  has_and_belongs_to_many :packages
  has_many :recipes
  has_many :colors
end
