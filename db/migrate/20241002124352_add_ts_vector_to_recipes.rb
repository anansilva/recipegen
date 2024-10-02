class AddTsVectorToRecipes < ActiveRecord::Migration[7.2]
  def up
    add_column :recipes, :ingredients_tsvector, :tsvector
    add_index :recipes, :ingredients_tsvector, using: :gin

    execute <<-SQL
      UPDATE recipes
      SET ingredients_tsvector = to_tsvector('english', array_to_string(ingredients, ' '))
    SQL

    execute <<-SQL
      CREATE TRIGGER ingredients_tsvector_update BEFORE INSERT OR UPDATE
      ON recipes FOR EACH ROW EXECUTE FUNCTION
      tsvector_update_trigger(ingredients_tsvector, 'pg_catalog.english', ingredients);
    SQL
  end

  def down
    execute "DROP TRIGGER ingredients_tsvector_update ON recipes;"
    remove_index :recipes, :ingredients_tsvector
    remove_column :recipes, :ingredients_tsvector
  end
end
