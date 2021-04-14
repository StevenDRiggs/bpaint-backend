class Avatar < ApplicationRecord
  has_one_attached :avatar_image

  belongs_to :user

  validates :url, presence: true, url: true
  validates :name, presence: true, name: true, profanity_filter: true


  # instance methods
  def as_json(options={})
     options[:except] ||= [:id, :created_at, :updated_at, :user_id]
     super(options)
   end
end
