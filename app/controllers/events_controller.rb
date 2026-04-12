class EventsController < ApplicationController
  before_action :set_event,      only: [:show, :edit, :update]
  before_action :verify_owner!,  only: [:edit, :update]

  # イベント作成フォームを表示する
  def new
    @event = Event.new
    @event.candidate_dates.build
  end

  # イベントと候補日時を一括保存する
  def create
    @event = Event.new(event_params)
    if @event.save
      set_owner_cookie(@event)   # 作成者としてCookieに記録
      redirect_to @event, notice: "イベントを作成しました！"
    else
      render :new, status: :unprocessable_entity
    end
  end

  # 保存後の完了・共有画面
  def show
    @is_owner = owner?(@event)
  end

  # 編集フォームを表示する（オーナーのみ）
  def edit
  end

  # イベントを更新する（オーナーのみ）
  def update
    if @event.update(event_params)
      redirect_to @event, notice: "イベントを更新しました！"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # AIによるスケジュール抽出（Turbo Streamで候補日時フォームを差し替えて返す）
  def extract_schedule
    @extracted_dates = ScheduleExtractorService.extract(params[:input_text] || "")
    respond_to do |format|
      format.turbo_stream
    end
  end

  private

  def set_event
    @event = Event.find(params[:id])
  end

  # イベントのオーナーかどうかを判定する
  def owner?(event)
    cookies.signed[owner_cookie_key(event)] == event.id
  end

  # オーナー用CookieキーはトークンをキーにしてIDを保存する
  def owner_cookie_key(event)
    "raku_suke_owner_#{event.token}"
  end

  # Cookie に作成者フラグを保存する（有効期限365日）
  def set_owner_cookie(event)
    cookies.signed[owner_cookie_key(event)] = {
      value: event.id,
      expires: 365.days.from_now,
      httponly: true
    }
  end

  # オーナー以外は show にリダイレクト
  def verify_owner!
    unless owner?(@event)
      redirect_to @event, alert: "このイベントを編集する権限がありません。"
    end
  end

  def event_params
    params.require(:event).permit(
      :title,
      :description,
      candidate_dates_attributes: [:id, :start_at, :end_at, :_destroy]
    )
  end
end
