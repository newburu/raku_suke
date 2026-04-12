// Stimulusコントローラー: 候補日時フォームの動的な行追加・削除・AI抽出制御
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["list", "template", "extractButton", "extractLabel", "item", "removeButton"]
  static values = { url: String }

  // 手動で行を1件追加する
  addRow() {
    const template = this.templateTarget.innerHTML
    const timestamp = new Date().getTime()
    const html = template.replaceAll("NEW_RECORD", timestamp)
    this.listTarget.insertAdjacentHTML("beforeend", html)
  }

  // 行を削除する（_destroyフラグを立てて非表示にする）
  remove(event) {
    const row = event.target.closest("[data-nested-form-target='item']")
    const destroyFlag = row.querySelector(".destroy-flag")
    if (destroyFlag) {
      destroyFlag.value = "true"
    }
    row.style.transition = "opacity 0.2s"
    row.style.opacity = "0"
    setTimeout(() => row.remove(), 200)
  }

  // AIによるスケジュール抽出を非同期で呼び出す
  async extractSchedule() {
    const inputText = document.getElementById("ai-input-text").value.trim()
    if (!inputText) {
      alert("テキストを入力してください。")
      return
    }

    const button = this.extractButtonTarget
    const label = this.extractLabelTarget

    // ローディング表示
    button.disabled = true
    label.textContent = "⏳ AI抽出中..."

    try {
      const csrfToken = document.querySelector('meta[name="csrf-token"]').content
      const response = await fetch(this.urlValue, {
        method: "POST",
        headers: {
          "Content-Type": "application/x-www-form-urlencoded",
          "Accept": "text/vnd.turbo-stream.html",
          "X-CSRF-Token": csrfToken
        },
        body: new URLSearchParams({ input_text: inputText })
      })

      if (response.ok) {
        const html = await response.text()
        // Turbo Streamのレスポンスを手動で適用する
        Turbo.renderStreamMessage(html)
        label.textContent = "✅ 抽出完了！内容を確認してください"
        setTimeout(() => { label.textContent = "✨ AIで候補日時を抽出" }, 3000)
      } else {
        label.textContent = "❌ 抽出に失敗しました"
        setTimeout(() => { label.textContent = "✨ AIで候補日時を抽出" }, 3000)
      }
    } catch (error) {
      console.error("抽出エラー:", error)
      label.textContent = "❌ エラーが発生しました"
      setTimeout(() => { label.textContent = "✨ AIで候補日時を抽出" }, 3000)
    } finally {
      button.disabled = false
    }
  }
}
