class CreateGroupings < ActiveRecord::Migration[8.0]
  def change
    create_table :groupings do |t|
      t.json :result
      t.references :event, null: false, foreign_key: true

      t.timestamps
    end
  end
end
