class Recipe < ApplicationRecord
  belongs_to :user
  belongs_to :package
  has_and_belongs_to_many :colors
end
