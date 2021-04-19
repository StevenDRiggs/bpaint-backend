class AddCreatorIdNameToPackages < ActiveRecord::Migration[6.1]
  def change
    add_column :packages, :creator_id, :integer, null: false
    add_column :packages, :name, :string, null: false
  end
end
