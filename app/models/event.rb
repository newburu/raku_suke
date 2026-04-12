class Event < ApplicationRecord
  has_many :candidate_dates, dependent: :destroy
  accepts_nested_attributes_for :candidate_dates,
    allow_destroy: true,
    reject_if: :all_blank

  validates :title, presence: true

  before_create :generate_token

  private

  # 共有用ユニークトークンを作成する
  def generate_token
    loop do
      self.token = SecureRandom.urlsafe_base64(10)
      break unless Event.exists?(token: self.token)
    end
  end
end
