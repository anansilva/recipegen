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

  private

  def select_sql(query)
    "recipes.*,
    ts_rank(ingredients_tsvector, to_tsquery('english', '#{query}')) AS rank,
    (cook_time + prep_time) AS total_time,
    array_length(ingredients, 1) AS total_ingredients,
    (SELECT COUNT(*) FROM unnest(string_to_array('#{query}', ' | '))
      AS ing WHERE ingredients_tsvector @@ to_tsquery('english', ing)) AS matched_ingredients_count,
    (SELECT array_agg(ing) FROM unnest(string_to_array('#{query}', ' | '))
      AS ing WHERE ingredients_tsvector @@ to_tsquery('english', ing)) AS matched_ingredients,
    array_length(ingredients, 1) - (SELECT COUNT(*) FROM unnest(string_to_array('#{query}', ' | '))
      AS ing WHERE ingredients_tsvector @@ to_tsquery('english', ing)) AS missing_ingredients"
  end

  def where_sql
    "ingredients_tsvector @@ to_tsquery('english', ?)"
  end

  def order_sql
    Arel.sql('matched_ingredients_count DESC, missing_ingredients ASC, rank DESC, rating DESC, total_time ASC')
  end

  def ingredients_query(ingredients)
    ingredients.map { |ingredient| ingredient.gsub(/\s+/, ' & ') }.join(' | ')
  end
end
