class AddGroupSizeToEvents < ActiveRecord::Migration[8.0]
  def change
    add_column :events, :group_size, :integer
  end
end
