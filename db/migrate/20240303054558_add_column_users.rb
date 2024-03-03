class AddColumnUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :provider, :string, null: false, after: :id
    add_column :users, :uid, :string, null: false, after: :provider
    add_column :users, :email, :string, null: false, after: :name
end
end
