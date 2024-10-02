class FixIngredientsTsvectorTrigger < ActiveRecord::Migration[7.2]
  def up
    execute <<-SQL
      DROP TRIGGER IF EXISTS ingredients_tsvector_update ON recipes;
    SQL

    execute <<-SQL
      DROP FUNCTION IF EXISTS update_ingredients_tsvector();
    SQL

    execute <<-SQL
      CREATE OR REPLACE FUNCTION update_ingredients_tsvector()
      RETURNS TRIGGER AS $$
      BEGIN
        NEW.ingredients_tsvector := to_tsvector('english',
          coalesce(array_to_string(NEW.ingredients, ' '), ''));
        RETURN NEW;
      END;
      $$ LANGUAGE plpgsql;
    SQL

    execute <<-SQL
      CREATE TRIGGER ingredients_tsvector_update
      BEFORE INSERT OR UPDATE ON recipes
      FOR EACH ROW
      EXECUTE FUNCTION update_ingredients_tsvector();
    SQL
  end

  def down
    execute "DROP TRIGGER IF EXISTS ingredients_tsvector_update ON recipes;"
    execute "DROP FUNCTION IF EXISTS update_ingredients_tsvector();"
  end
end
