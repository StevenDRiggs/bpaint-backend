class Color < ApplicationRecord
  has_one_attached :color_image

  belongs_to :user
  has_and_belongs_to_many :recipes

  validates :url, presence: true, url: true
  validates :name, presence: true, name: true, profanity_filter: true
  validates :medium, presence: true, name: true, profanity_filter: true
end
