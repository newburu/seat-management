class EventsController < ApplicationController
  before_action :authenticate_user!
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found


  def index
    @events = current_user.events.order(created_at: :desc)
  end

  def new
    @event = current_user.events.build
    @event.participant_attributes_config = [{ label: "所属", required: true }, { label: "役職", required: false }]
  end

  def create
    @event = current_user.events.build(event_params)
    if @event.save
      redirect_to @event, notice: "イベントを作成しました。"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    @event = current_user.events.find(params[:id])
    @event.destroy
    redirect_to events_path, notice: "イベントを削除しました。", status: :see_other
  end

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
    permitted = params.require(:event).permit(:name, :group_size)
    
    if params[:event][:participant_attributes_config].present?
      # Convert hash with indices to array of permitted params
      configs = params[:event][:participant_attributes_config].values
      permitted[:participant_attributes_config] = configs.map do |config|
        config.permit(:label, :required)
      end
    end
    
    permitted
  end

  def record_not_found
    redirect_to events_path, alert: "イベントが見つかりません、またはアクセス権がありません。"
  end
end
