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

    # event = current_user.events.create!(name: "Guest Event #{Time.current.strftime('%Y-%m-%d %H:%M')}")
    # Simplified name for guest
    event = current_user.events.create!(name: "ゲストイベント #{Time.current.strftime('%m/%d %H:%M')}")

    redirect_to event_path(event), notice: "イベントを作成しました。"
  rescue StandardError => e
    Rails.logger.error("Guest Error: #{e.message}")
    redirect_to root_path, alert: "エラーが発生しました: #{e.message}"
  end
end
