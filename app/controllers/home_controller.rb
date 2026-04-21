class HomeController < ApplicationController
  def index
    # Cookieから自分が作成したイベントのトークンを抽出
    # cookie key format: raku_suke_owner_{token}
    owner_tokens = request.cookies.keys.map { |k| k.match(/^raku_suke_owner_(.+)/) { |m| m[1] } }.compact
    @created_events = Event.where(token: owner_tokens).order(created_at: :desc)

    # Cookieから自分が回答したイベントのトークンを抽出
    # cookie key format: raku_suke_event_{token}
    voted_tokens = request.cookies.keys.map { |k| k.match(/^raku_suke_event_(.+)/) { |m| m[1] } }.compact
    
    @voted_events = Event.where(token: voted_tokens).order(created_at: :desc)
  end
end
