json.extract! attendee, :id, :event_id, :name, :user_id, :created_at, :updated_at
json.url attendee_url(attendee, format: :json)
