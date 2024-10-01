require 'rails_helper'

RSpec.describe "Recipes", type: :request do
  describe "GET /recipes" do
    let!(:recipe1) { create(:recipe, title: 'Recipe1') }
    let!(:recipe2) { create(:recipe, title: 'Recipe2') }

    context "when ingredients are present" do
      it "splits and strips the ingredients and passes them to RecipeQuery" do
        recipe_query = instance_double(RecipeQuery)

        expect(RecipeQuery).to receive(:new).and_return(recipe_query)
        expect(recipe_query).to receive(:search).with(['tomato', 'onion', 'garlic']).and_return(Recipe.all)

        get recipes_path, params: { ingredients: 'tomato, onion, garlic' }

        expect(response).to have_http_status(:success)
      end
    end

    context "when ingredients are not present" do
      it "assigns an empty array to @ingredients" do
        recipe_query = instance_double(RecipeQuery)

        expect(RecipeQuery).to receive(:new).and_return(recipe_query)
        expect(recipe_query).to receive(:search).with([]).and_return(Recipe.none)

        get recipes_path

        expect(response).to have_http_status(:success)
      end
    end
  end
end
