class RecipeQuery
  attr_reader :relation

  def initialize(relation = Recipe)
    @relation = relation
  end

  def search(ingredients = [])
    return relation.none if ingredients.empty?

    query = ingredients_query(ingredients)

    relation
      .select(select_sql(query))
      .where(where_sql, query)
      .order(order_sql)
  end

  def select_sql(query)
    "recipes.*,
    ts_rank(ingredients_tsvector, to_tsquery('english', '#{query}')) AS rank,
    (cook_time + prep_time) AS total_time,
    (SELECT COUNT(*) FROM unnest(string_to_array(array_to_string(ingredients, ' '), ' ')) AS ing
      WHERE to_tsvector('english', ing) @@ to_tsquery('english', '#{query}')) AS matched_count,
    array_length(ingredients, 1) AS total_ingredients"
  end

  def where_sql
    "ingredients_tsvector @@ to_tsquery('english', ?)"
  end

  def order_sql
    Arel.sql('matched_count DESC, rank DESC, matched_count DESC, rating DESC, total_time ASC')
  end

  def ingredients_query(ingredients)
    ingredients.map { |ingredient| ingredient.gsub(/\s+/, ' & ') }.join(' | ')
  end
end
