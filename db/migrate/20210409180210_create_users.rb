class CreateUsers < ActiveRecord::Migration[6.1]
  def change
    create_table :users do |t|
      t.string :username, null: false
      t.string :password_digest, null: false
      t.integer :avatar_id, default: -1
      t.json :flags, null: false, default: {}
      t.json :packages, null: false, default: {}
      t.boolean :is_admin, null: false, default: false

      t.timestamps
    end
  end
end
