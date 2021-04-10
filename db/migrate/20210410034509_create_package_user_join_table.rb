class CreatePackageUserJoinTable < ActiveRecord::Migration[6.1]
  def change
    create_join_table :packages, :users do |t|
      t.index :package_id
      t.index :user_id
    end
  end
end
