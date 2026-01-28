class ParticipantsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_event

  def create
    @participant = @event.participants.build(participant_params)
    
    # Transform properties array [{key: k, value: v}, ...] to hash {k => v, ...}
    if params[:participant][:properties_attributes]
      properties_hash = {}
      params[:participant][:properties_attributes].values.each do |prop|
        properties_hash[prop[:key]] = prop[:value] if prop[:key].present?
      end
      @participant.properties = properties_hash
    end

    if @participant.save
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to event_path(@event), notice: '参加者を追加しました。' }
      end
    else
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.replace('new_participant', partial: 'participants/form', locals: { event: @event, participant: @participant }) }
        format.html { redirect_to event_path(@event), alert: '参加者の追加に失敗しました。' }
      end
    end
  end

  def destroy
    @participant = @event.participants.find(params[:id])
    @participant.destroy

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to event_path(@event), notice: '参加者を削除しました。' }
    end
  end

  private

  def set_event
    @event = current_user.events.find(params[:event_id])
  end

  def participant_params
    params.require(:participant).permit(:name)
  end
end
