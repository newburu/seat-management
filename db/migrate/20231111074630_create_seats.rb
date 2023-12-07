class CreateSeats < ActiveRecord::Migration[7.1]
  def change
    create_table :seats do |t|
      t.references :event, null: false, foreign_key: true
      t.integer :no
      t.references :attendee, null: false, foreign_key: true

      t.timestamps
    end
  end
end
