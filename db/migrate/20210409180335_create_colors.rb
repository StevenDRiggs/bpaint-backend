class CreateColors < ActiveRecord::Migration[6.1]
  def change
    create_table :colors do |t|
      t.string :url, null: false
      t.string :medium, null: false
      t.string :name, null: false
      t.integer :user_id, null: false
      t.boolean :verified, null: false, default: false

      t.timestamps
    end
  end
end
