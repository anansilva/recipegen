class RecipesController < ApplicationController
  def index
    @ingredients = params[:ingredients].present? ? params[:ingredients].split(',').map(&:strip) : []
    @pagy, @recipes = pagy(fetch_recipes(@ingredients), items: 10, limit: 10)

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.update('search_results', partial: 'recipes/recipes_list',
                                                                   locals: partial_data)
      end
      format.html
    end
  end

  private

  def fetch_recipes(ingredients)
    RecipeQuery.new.search(ingredients)
  end

  def partial_data
    { recipes: @recipes, ingredients: @ingredients, recipes_total_count: @recipes_total_count }
  end
end
