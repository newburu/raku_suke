Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  resources :events, only: [:new, :create, :show] do
    collection do
      post :extract_schedule
    end
  end

  # トークンURLで参加者が回答するページ（tokenはevents.tokenカラムの値）
  scope "/event/:token" do
    get    "respond", to: "attendances#new",     as: :respond_event
    post   "attend",  to: "attendances#create",  as: :attend_event
    get    "result",  to: "attendances#result",  as: :result_event
    get    "thanks",  to: "attendances#thanks",  as: :thanks_event
    delete "attend",  to: "attendances#destroy", as: :destroy_attendance
  end

  # ルートは暫定でevents#newを指定
  root "events#new"
end
