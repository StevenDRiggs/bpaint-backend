class Avatar < ApplicationRecord
  has_one_attached :avatar_image

  belongs_to :user
end
