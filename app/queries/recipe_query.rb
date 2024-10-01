class RecipeQuery
  attr_reader :relation

  def initialize(relation = Recipe)
    @relation = relation
  end

  def search(ingredients = [])
    return relation.none if ingredients.empty?

    search_patterns = ingredients.map { |ingredient| "%#{ingredient}%" }
    relation.where("array_to_string(ingredients, ',') ILIKE ANY (ARRAY[?])", search_patterns)
  end
end
