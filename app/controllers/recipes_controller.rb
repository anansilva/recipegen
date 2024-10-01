class RecipesController < ApplicationController
  def index
    @ingredients = params[:ingredients].present? ? params[:ingredients].split(',').map(&:strip) : []
    @recipes = fetch_recipes(@ingredients)

    respond_to do |format|
      format.turbo_stream { render partial: 'recipes_list', locals: { recipes: @recipes } }
      format.html
    end
  end

  private

  def fetch_recipes(ingredients)
    RecipeQuery.new.search(ingredients)
  end
end
