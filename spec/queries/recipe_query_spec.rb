require 'rails_helper'

RSpec.describe RecipeQuery do
  describe '#search' do
    let!(:recipe1) { create(:recipe, title: "Golden Sweet Cornbread", cook_time: 25, prep_time: 10, rating: 4.74,
                                     image_link: "https://example.com/image1.jpg", author: "bluegirl",
                                     ingredients: ["1 cup all-purpose flour", "1 cup yellow cornmeal", "⅔ cup white sugar",
                                                   "1 teaspoon salt", "3 ½ teaspoons baking powder", "1 egg", "1 cup milk",
                                                   "⅓ cup vegetable oil"]) }

    let!(:recipe2) { create(:recipe, title: "Spicy Chicken Wings", cook_time: 30, prep_time: 15, rating: 4.5,
                                     image_link: "https://example.com/image2.jpg", author: "chefjohn",
                                     ingredients: ["2 pounds chicken wings", "1 teaspoon salt", "2 tablespoons hot sauce",
                                                   "1 tablespoon garlic powder"]) }

    let!(:recipe3) { create(:recipe, title: "Vegetable Stir Fry", cook_time: 20, prep_time: 5, rating: 4.2,
                                     image_link: "https://example.com/image3.jpg", author: "veganlover",
                                     ingredients: ["1 cup broccoli", "1 cup bell pepper", "1 tablespoon soy sauce",
                                                   "1 tablespoon sesame oil"]) }

    let(:recipe_query) { described_class.new }

    context 'when no ingredients are provided' do
      it 'returns an empty recipe collection' do
        recipes = recipe_query.search([])
        expect(recipes).to eq(Recipe.none)
      end
    end

    context 'when one or more ingredients are provided' do
      it 'returns recipes that match the given ingredients' do
        recipes = recipe_query.search(["chicken"])
        expect(recipes).to include(recipe2)
        expect(recipes).not_to include(recipe1, recipe3)
      end

      it 'returns more than one matching recipe for a single ingredient' do
        recipes = recipe_query.search(["salt"])
        expect(recipes).to include(recipe1, recipe2)
        expect(recipes).not_to include(recipe3)
      end

      it 'returns recipes that match multiple ingredients' do
        recipes = recipe_query.search(["corn", "garlic"])
        expect(recipes).to include(recipe1, recipe2)
        expect(recipes).not_to include(recipe3)
      end

      it 'returns an empty collection if no recipes match the ingredients' do
        recipes = recipe_query.search(["nonexistent ingredient"])
        expect(recipes).to be_empty
      end
    end
  end
end
