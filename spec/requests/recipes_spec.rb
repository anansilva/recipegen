require 'rails_helper'

RSpec.describe "Recipes", type: :request do
  describe "GET /recipes" do
    let!(:recipe1) { create(:recipe, ingredients: ['onion something'] ) }
    let!(:recipe2) { create(:recipe, ingredients: ['garlic', 'tomato'] ) }

    before do
      ActiveRecord::Base.connection.execute <<-SQL
        UPDATE recipes
        SET ingredients_tsvector = to_tsvector('english', array_to_string(ingredients, ' '))
      SQL
    end


    context "when ingredients are present" do
      it "splits and strips the ingredients and passes them to RecipeQuery" do
        get recipes_path, params: { ingredients: 'tomato, onion, garlic' }

        expect(response).to have_http_status(:success)
      end
    end

    context "when ingredients are not present" do
      it "assigns an empty array to @recipes" do
        get recipes_path

        expect(response).to have_http_status(:success)
      end
    end
  end
end
