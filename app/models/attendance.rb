class Attendance < ApplicationRecord
  belongs_to :event

  # text カラムに JSON を安全にシリアライズ／デシリアライズする
  serialize :responses, coder: JSON

  validates :user_name, presence: true
  validates :user_name, uniqueness: { scope: :event_id, message: "はこのイベントですでに回答済みです" }

  # responses は {"1" => "ok", "2" => "maybe", "3" => "ng"} 形式
  # ok=○, maybe=△, ng=×
  VALID_RESPONSES = %w[ok maybe ng].freeze
end
