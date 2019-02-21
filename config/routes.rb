Rails.application.routes.draw do
  resources :users
  resources :comments

  root 'users#index'
end
