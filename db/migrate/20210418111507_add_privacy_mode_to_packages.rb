class AddPrivacyModeToPackages < ActiveRecord::Migration[6.1]
  def change
    add_column :packages, :privacy_mode, :string, null: false, default: 'PRIVATE'
  end
end
