class Color < ApplicationRecord
  has_one_attached :color_image

  belongs_to :user
  has_and_belongs_to_many :recipes
end
