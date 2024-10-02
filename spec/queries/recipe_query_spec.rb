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

    let!(:recipe4) { create(:recipe, title: "Coconut Curry", cook_time: 30, prep_time: 10, rating: 4.8,
                                     image_link: "https://example.com/image4.jpg",
                                    author: "curryking",
                                    ingredients: ["1 can coconut milk", "1 cup chickpeas", "1 cup spinach",
                                                  "2 tablespoons curry powder", "1 tablespoon olive oil",
                                                  "1 teaspoon cumin", "1 teaspoon turmeric", "1/2 cup diced tomato",
                                                  "Salt to taste", "tomatoes"])}

    let!(:recipe5) { create(:recipe, title: "Buttermilk Pancakes", cook_time: 15, prep_time: 10, rating: 4.9,
                                     image_link: "https://example.com/image_buttermilk.jpg",
                                     author: "pancakequeen",
                                     ingredients: ["2 cups all-purpose flour", "2 tablespoons sugar",
                                                   "1 teaspoon baking powder", "1 teaspoon baking soda",
                                                   "1/2 teaspoon salt", "2 cups buttermilk",
                                                   "2 large eggs", "1/4 cup melted butter", "tomato",
                                                   "1 teaspoon vanilla extract"]) }

    before do
      ActiveRecord::Base.connection.execute <<-SQL
        UPDATE recipes
        SET ingredients_tsvector = to_tsvector('english', array_to_string(ingredients, ' '))
      SQL
    end

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
        expect(recipes).not_to include(recipe1, recipe3, recipe4, recipe5)
      end

      it 'is case insensitive' do
        recipes = recipe_query.search(["Chicken"])
        expect(recipes).to include(recipe2)
        expect(recipes).not_to include(recipe1, recipe3, recipe4, recipe5)
      end

      it 'returns more than one matching recipe for a single ingredient' do
        recipes = recipe_query.search(["salt"])

        expect(recipes).to include(recipe1, recipe2, recipe4, recipe5)
        expect(recipes).not_to include(recipe3)
      end

      it 'returns recipes that match multiple ingredients' do
        recipes = recipe_query.search(["cornmeal", "garlic"])

        expect(recipes).to include(recipe1, recipe2)
        expect(recipes).not_to include(recipe3, recipe4, recipe5)
      end

      it 'returns an empty collection if no recipes match the ingredients' do
        recipes = recipe_query.search(["nonexistent ingredient"])
        expect(recipes).to be_empty
      end

      it 'returns recipes that match multiple ingredients even if some are nonexistent' do
        recipes = recipe_query.search(["cornmeal", "garlic", "nonexistent ingredient"])

        expect(recipes).to include(recipe1, recipe2)
        expect(recipes).not_to include(recipe3, recipe4, recipe5)
      end

    end

    # i would like coconut milk not to be considered here because it's not the same ingredient, how can we do that
    context 'composed ingredients containing words of other ingredients' do
      it 'does the exact match of ingredients (milk is not buttermilk)' do
        recipes = recipe_query.search(["milk"])

        expect(recipes).to include(recipe1, recipe4)
        expect(recipes).not_to include(recipe2, recipe3, recipe5)
      end

      it 'does the exact match of ingredients (buttermilk is not milk)' do
        recipes = recipe_query.search(["buttermilk"])

        expect(recipes).to include(recipe5)
        expect(recipes).not_to include(recipe1, recipe2, recipe3, recipe4)
      end
    end

    context 'ingredients with more than one word' do
      it 'does the exact match of the ingredients' do
        recipes = recipe_query.search(["coconut milk"])

        expect(recipes).to include(recipe4)
        expect(recipes).not_to include(recipe1, recipe2, recipe3, recipe5)
      end
    end

    context 'when searching with relevancy ordering' do
      it 'returns recipes ordered by the count of the searched ingredients included in the recipe' do
        recipes = recipe_query.search(["buttermilk", "flour"])
        expect(recipes).to eq([recipe5, recipe1])
      end

      context 'when count of ingredients is the same' do
        it 'returns recipes ordered by rating' do
          recipes = recipe_query.search(["salt", "flour"])
          expect(recipes).to eq([recipe5, recipe1, recipe4, recipe2])
        end
      end

      context 'when ingredients are repeated but in singular/plural forms' do
        it 'returns recipes ordered by rating' do
          recipes = recipe_query.search(["tomato"])
          expect(recipes).to eq([recipe4, recipe5])
        end
      end
    end
  end
end
