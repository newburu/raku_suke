class AttendancesController < ApplicationController
  before_action :set_event
  before_action :load_existing_attendance, only: [:new, :create, :destroy]

  # 参加者の回答フォームを表示する
  def new
    # @attendance は load_existing_attendance で既存があれば設定済み
    @attendance ||= Attendance.new
  end

  # 参加者の回答を保存する（新規 or Cookie に紐づく既存を上書き）
  def create
    responses_raw = params.dig(:attendance, :responses)
    responses_hash = responses_raw.respond_to?(:to_unsafe_h) ? responses_raw.to_unsafe_h : {}
    user_name = params.dig(:attendance, :user_name)
    comment   = params.dig(:attendance, :comment).to_s.strip

    if @attendance
      # --- 既存の回答を上書き更新 ---
      if @attendance.update(user_name: user_name, responses: responses_hash, comment: comment)
        set_attendance_cookie(@attendance)
        redirect_to thanks_event_path(token: @event.token), notice: "回答を更新しました！"
      else
        render :new, status: :unprocessable_entity
      end
    else
      # --- 新規作成 ---
      @attendance = @event.attendances.new(user_name: user_name, responses: responses_hash, comment: comment)
      if @attendance.save
        set_attendance_cookie(@attendance)
        redirect_to thanks_event_path(token: @event.token), notice: "回答ありがとうございました！"
      else
        render :new, status: :unprocessable_entity
      end
    end
  end

  # 自分の回答を削除する（Cookie も合わせて削除）
  def destroy
    if @attendance
      @attendance.destroy
      cookies.delete(cookie_key)
      redirect_to respond_event_path(token: @event.token), notice: "回答を削除しました。"
    else
      redirect_to respond_event_path(token: @event.token), alert: "削除できる回答が見つかりません。"
    end
  end

  # 回答完了ページ
  def thanks
  end

  # トークンURLでイベント詳細（show）を表示する
  def show_event
    @is_owner = cookies.signed["raku_suke_owner_#{@event.token}"] == @event.id
    if @is_owner
      render template: "events/show"
    else
      # 作成者以外は集計ページへ
      redirect_to result_event_path(token: @event.token)
    end
  end

  # 主催者向け集計ページ
  def result
    @attendances = @event.attendances.order(:created_at)
    @candidate_dates = @event.candidate_dates.order(:start_at)
  end

  private

  # tokenからEventを取得する（見つからない場合は404）
  def set_event
    @event = Event.find_by!(token: params[:token])
  rescue ActiveRecord::RecordNotFound
    render plain: "イベントが見つかりません", status: :not_found
  end

  # Cookieから既存の Attendance を取得する
  def load_existing_attendance
    attendance_id = cookies.signed[cookie_key]
    return unless attendance_id

    @attendance = @event.attendances.find_by(id: attendance_id)
    # 念のため別イベントのCookieが混入していないか確認
    cookies.delete(cookie_key) if @attendance.nil?
  end

  # CookieにAttendance IDを署名付きで保存する（有効期限：30日）
  def set_attendance_cookie(attendance)
    cookies.signed[cookie_key] = {
      value: attendance.id,
      expires: 30.days.from_now,
      httponly: true
    }
  end

  # イベントごとに一意なCookieキー
  def cookie_key
    "raku_suke_event_#{@event.token}"
  end
end
