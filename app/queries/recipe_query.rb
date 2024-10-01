class RecipeQuery
  attr_reader :relation

  def initialize(relation = Recipe)
    @relation = relation
  end

  def search(ingredients = [])
    return relation.none if ingredients.empty?

    relation.where("array_to_string(ingredients, ' ') ~* ANY (ARRAY[?])", search_patterns(ingredients))
            .select("recipes.*, #{matching_ingredients_count(ingredients)} AS matching_ingredients_count")
            .order(Arel.sql('matching_ingredients_count DESC, rating DESC'))
  end

  private

  def search_patterns(ingredients)
    ingredients.flat_map do |ingredient|
      pluralized_ingredient = ingredient.pluralize
      singularized_ingredient = ingredient.singularize
      [
        "\\m#{Regexp.escape(singularized_ingredient)}\\M",
        "\\m#{Regexp.escape(pluralized_ingredient)}\\M"
      ]
    end
  end

  def matching_ingredients_count(ingredients)
    patterns = search_patterns(ingredients).map do |pattern|
      "CASE WHEN array_to_string(ingredients, ' ') ~* '#{pattern}' THEN 1 ELSE 0 END"
    end
    "(#{patterns.join(' + ')})"
  end
end
