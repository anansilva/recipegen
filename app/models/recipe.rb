class Recipe < ApplicationRecord
  belongs_to :category, optional: true
  belongs_to :cuisine, optional: true

  validates :title, :ingredients, presence: true
end
