class EventsController < ApplicationController
  # イベント作成フォームを表示する
  def new
    @event = Event.new
    @event.candidate_dates.build
  end

  # イベントと候補日時を一括保存する
  def create
    @event = Event.new(event_params)
    if @event.save
      redirect_to @event, notice: "イベントを作成しました！"
    else
      render :new, status: :unprocessable_entity
    end
  end

  # 保存後の完了・共有画面
  def show
    @event = Event.find(params[:id])
  end

  # AIによるスケジュール抽出（Turbo Streamで候補日時フォームを差し替えて返す）
  def extract_schedule
    @extracted_dates = ScheduleExtractorService.extract(params[:input_text] || "")
    respond_to do |format|
      format.turbo_stream
    end
  end

  private

  def event_params
    params.require(:event).permit(
      :title,
      :description,
      candidate_dates_attributes: [:id, :start_at, :end_at, :_destroy]
    )
  end
end
