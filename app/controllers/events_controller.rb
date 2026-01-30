class EventsController < ApplicationController
  before_action :authenticate_user!

  def show
    @event = current_user.events.find(params[:id])
    @participants = @event.participants
  end
  def edit
    @event = current_user.events.find(params[:id])
  end

  def update
    @event = current_user.events.find(params[:id])
    if @event.update(event_params)
      redirect_to @event, notice: "イベント情報を更新しました。"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def event_params
    params.require(:event).permit(:name)
  end
end
