class GuestsController < ApplicationController
  def create
    # 1. Create Guest User if not signed in
    unless user_signed_in?
      user = User.create!(
        provider: "guest",
        uid: SecureRandom.uuid,
        name: "Guest User",
        email: nil,
        password: nil
      )
      sign_in(user)
    end

    # 2. Create Event (Empty)
    event = current_user.events.create!(name: "Guest Event #{Time.current.strftime('%Y-%m-%d %H:%M')}")

    redirect_to event_path(event), notice: "Event created successfully."
  rescue StandardError => e
    Rails.logger.error("Guest Error: #{e.message}")
    redirect_to root_path, alert: "An error occurred: #{e.message}"
  end
end
