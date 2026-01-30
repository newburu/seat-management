class ParticipantsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_event
  before_action :set_participant, only: [:destroy, :edit, :update]

  def create
    @participant = @event.participants.build(participant_params)
    assign_properties
    
    if @participant.save
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to event_path(@event), notice: '参加者を追加しました。' }
      end
    else
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.update('new_participant_frame', partial: 'participants/form', locals: { event: @event, participant: @participant }) }
        format.html { redirect_to event_path(@event), alert: '参加者の追加に失敗しました。' }
      end
    end
  end

  def edit
    # Turbo Frame will handle rendering just the form in place of the participant row
  end

  def update
    @participant.assign_attributes(participant_params)
    assign_properties

    if @participant.save
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to event_path(@event), notice: '参加者情報を更新しました。' }
      end
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
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

  def set_participant
    @participant = @event.participants.find(params[:id])
  end

  def participant_params
    params.require(:participant).permit(:name)
  end

  def assign_properties
    # Transform properties array [{key: k, value: v}, ...] to hash {k => v, ...}
    if params[:participant][:properties_attributes]
      properties_hash = {}
      params[:participant][:properties_attributes].values.each do |prop|
        properties_hash[prop[:key]] = prop[:value] if prop[:key].present?
      end
      @participant.properties = properties_hash
    else
      # If no properties sent (e.g. all removed), clear it
      @participant.properties = {} if action_name == 'update'
    end
  end
end
