class RecipeQuery
  attr_reader :relation

  def initialize(relation = Recipe)
    @relation = relation
  end

  def search(ingredients = [])
    return relation.none if ingredients.empty?

    query = ingredients_query(ingredients)

    relation
      .select("recipes.*,
                ts_rank(to_tsvector('english', array_to_string(ingredients, ' ')), to_tsquery('english', '#{query}')) AS rank,
                (cook_time + prep_time) AS total_time,
                (SELECT COUNT(*) FROM unnest(string_to_array(array_to_string(ingredients, ' '), ' ')) AS ing
                 WHERE to_tsvector('english', ing) @@ to_tsquery('english', '#{query}')) AS matched_count,
                array_length(ingredients, 1) AS total_ingredients")
      .where("to_tsvector('english', array_to_string(ingredients, ' ')) @@ to_tsquery('english', ?)", query)
      .order(Arel.sql('matched_count DESC, rank DESC, matched_count DESC, rating DESC, total_time ASC'))
  end

  def ingredients_query(ingredients)
    ingredients.map { |ingredient| ingredient.gsub(/\s+/, ' & ') }.join(' | ')
  end
end
