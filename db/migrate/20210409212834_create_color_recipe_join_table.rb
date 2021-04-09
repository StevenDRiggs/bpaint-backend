class CreateColorRecipeJoinTable < ActiveRecord::Migration[6.1]
  def change
    create_join_table :colors, :recipes do |t|
      t.index :color_id
      t.index :recipe_id
    end
  end
end
