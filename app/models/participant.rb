class Participant < ApplicationRecord
  belongs_to :event
  serialize :properties, coder: JSON
  
  validates :name, presence: true, length: { maximum: 20 }
  validate :validate_required_properties

  private

  def validate_required_properties
    return unless event&.participant_attributes_config.present?

    event.participant_attributes_config.each do |config|
      next unless config['required'].to_s == '1' || config['required'] == true
      
      label = config['label']
      if properties[label].blank?
        errors.add(:base, "#{label}は必須項目です")
      end
    end
  end
end
