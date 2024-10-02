class Recipe < ApplicationRecord
  belongs_to :category, optional: true
  belongs_to :cuisine, optional: true

  validates :title, :ingredients, presence: true

  def self.pg_search_tsvector(ingredients)
    Arel.sql("to_tsvector('english', #{ingredients.join(' ')})")
  end
end
