class CreateParticipants < ActiveRecord::Migration[7.1]
  def change
    create_table :participants do |t|
      t.string :name
      t.json :properties
      t.references :event, null: false, foreign_key: true

      t.timestamps
    end
  end
end
