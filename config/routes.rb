Rails.application.routes.draw do
  resources :users
  resources :projects
  post "project/:id/framework/:framework_id", to: "projects#add_framework"
  delete "project/:id/framework/:framework_id", to: "projects#remove_framework"
  post "project/:id/framework/:framework_id/use_case/:use_case_name", to: "projects#add_framework_use_case"
  delete "project/:id/framework/:framework_id/use_case/:use_case_id", to: "projects#remove_framework_use_case"
  resources :languages

  scope "language/:language_id", module: "language", as: "language" do
    resources :frameworks
    post "/frameworks/:id/add_use_case", to: "frameworks#add_use_case"
    delete "/frameworks/:id/remove_use_case/:use_case_id", to: "frameworks#remove_use_case"
  end
  # get "/user", to: "users#show"

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  post "/login", to: "authentication#login"
  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  # Defines the root path route ("/")
  # root "posts#index"
end
