require 'faraday'
require 'json'

class ScheduleExtractorService
  API_URL = "https://generativelanguage.googleapis.com/v1beta/models/gemini-flash-latest:generateContent"

  SYSTEM_PROMPT_TEMPLATE = <<~PROMPT
    あなたはスケジュール調整アシスタントです。入力テキストから候補日時を抽出し、以下のJSON配列のみを出力してください。挨拶や説明は不要です。

    抽出ルール

    基準日: 今日は %{current_date} です。相対的な日付（明日、来週など）はこれから計算してください。

    デフォルト時間:
    午前: 09:00 - 12:00
    午後: 13:00 - 18:00
    夜: 18:00 - 21:00
    指定なし: 10:00 - 18:00

    出力フォーマット:
    [{"start_at": "YYYY-MM-DD HH:mm", "end_at": "YYYY-MM-DD HH:mm"}]

    エラー時: 抽出不能な場合は空配列 [] を返してください。
  PROMPT

  def self.extract(text)
    api_key = ENV['GEMINI_API_KEY'] || ENV['GOOGLE_API_KEY']
    return [] if api_key.blank? || text.blank?

    current_date = Time.current.strftime("%Y-%m-%d (%a)")
    system_instruction = format(SYSTEM_PROMPT_TEMPLATE, current_date: current_date)

    request_body = {
      systemInstruction: {
        parts: [{ text: system_instruction }]
      },
      contents: [
        { parts: [{ text: text }] }
      ],
      generationConfig: {
        responseMimeType: "application/json"
      }
    }

    conn = Faraday.new(url: API_URL) do |f|
      f.request :url_encoded
      f.adapter Faraday.default_adapter
    end

    begin
      response = conn.post do |req|
        req.params['key'] = api_key
        req.headers['Content-Type'] = 'application/json'
        req.body = request_body.to_json
      end

      if response.success?
        response_data = JSON.parse(response.body)
        content_text = response_data.dig("candidates", 0, "content", "parts", 0, "text") || "[]"
        JSON.parse(content_text)
      else
        Rails.logger.error("Gemini API Error: #{response.status} #{response.body}")
        []
      end
    rescue JSON::ParserError => e
      Rails.logger.error("JSON Parser Error: #{e.message}")
      []
    rescue StandardError => e
      Rails.logger.error("ScheduleExtractorService Error: #{e.message}")
      []
    end
  end
end
