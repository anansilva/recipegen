class RecipeQuery
  attr_reader :relation

  def initialize(relation = Recipe)
    @relation = relation
  end

  def search(ingredients = [])
    return relation.none if ingredients.empty?

    relation.where("array_to_string(ingredients, ' ') ~* ANY (ARRAY[?])", search_patterns(ingredients))
            .select("recipes.*,
                     #{matching_ingredients_count(ingredients)} AS matching_ingredients_count,
                     (cook_time + prep_time) AS total_time")
            .order(Arel.sql('matching_ingredients_count DESC, rating DESC, total_time ASC'))
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
    end.uniq
  end

  def matching_ingredients_count(ingredients)
    count_cases = ingredients.map { |ingredient| build_case_statement(ingredient) }.join(' + ')
    "COALESCE(#{count_cases}, 0)"
  end

  def build_case_statement(ingredient)
    singularized_ingredient = ingredient.singularize
    pluralized_ingredient = ingredient.pluralize

    <<-SQL
      CASE
        WHEN array_to_string(ingredients, ' ') ~* '\\m#{Regexp.escape(singularized_ingredient)}\\M' OR
             array_to_string(ingredients, ' ') ~* '\\m#{Regexp.escape(pluralized_ingredient)}\\M'
        THEN 1
        ELSE NULL
      END
    SQL
  end
end
