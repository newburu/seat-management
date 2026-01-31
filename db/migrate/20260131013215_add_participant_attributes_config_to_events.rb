class AddParticipantAttributesConfigToEvents < ActiveRecord::Migration[8.0]
  def change
    add_column :events, :participant_attributes_config, :json
  end
end
