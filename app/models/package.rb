class Package < ApplicationRecord
  has_and_belongs_to_many :users
  has_many :recipes

  validates :name, presence: true, profanity_filter: true
  validates :creator_id, presence: true


  #instance methods
  def as_json(options={})
     options[:except] ||= [:id, :created_at, :updated_at]
     super(options)
   end
end
