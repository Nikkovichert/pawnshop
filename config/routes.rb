Rails.application.routes.draw do
  devise_for :users
  root 'games#index'
  resources :games do
  end
end



