class User < ApplicationRecord
  has_secure_password
  
  has_one :avatar
  has_and_belongs_to_many :packages
  has_many :recipes
  has_many :colors

  validates :username, name: true, profanity_filter: true, uniqueness: true
  validates :email, presence: true, email: true, uniqueness: true
  validates :password, presence: true, password: true


  # class methods
  def self.find_by_username_or_email(username_or_email)
    user = self.find_by(username: username_or_email)

    unless user
      user = self.find_by(email: username_or_email)
    end

    user
  end


  # instance methods
  def as_json(options={})
     options[:except] ||= [:id, :created_at, :updated_at, :password_digest]
     super(options)
   end
end
