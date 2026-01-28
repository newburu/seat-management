class GroupingsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_event

  def create
    @participants = @event.participants

    if @participants.empty?
      redirect_to event_path(@event), alert: "参加者がいないためグルーピングを実行できません。"
      return
    end

    begin
      # GroupingService should return JSON object { "groups": [...] }
      result = Ai::GroupingService.new(@event).call
      
      @grouping = @event.groupings.create!(result: result)

      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to event_path(@event), notice: "グルーピングが完了しました。" }
      end
    rescue => e
      redirect_to event_path(@event), alert: "グルーピングに失敗しました: #{e.message}"
    end
  end

  private

  def set_event
    @event = current_user.events.find(params[:event_id])
  end
end
