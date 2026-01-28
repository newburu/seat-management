class EventsController < ApplicationController
  before_action :authenticate_user!

  def show
    @event = current_user.events.find(params[:id])
    @participants = @event.participants
  end
end
