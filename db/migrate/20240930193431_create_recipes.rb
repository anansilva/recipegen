class CreateRecipes < ActiveRecord::Migration[7.0]
  def change
    create_table :recipes do |t|
      t.string :title
      t.integer :cook_time
      t.integer :prep_time
      t.float :rating
      t.string :image_link
      t.string :author
      t.text :ingredients
      t.references :category, null: true, foreign_key: true
      t.references :cuisine, null: true, foreign_key: true

      t.timestamps
    end
  end
end
