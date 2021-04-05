Rails.application.routes.draw do
  resources :editions
  devise_for :users
  resources :questions
  resources :proofs
  resources :registries
  resources :users
  resources :profiles

  devise_scope :user do
    post "sign_up", to: "registrations#create"
    post "sign_in", to: "sessions#create"
  end

  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
