Rails.application.routes.draw do

  ##root to: 'visitors#index'
  root to: 'terminal_movs#index'
  
  
  devise_for :users
  resources :users
  
  get ':controller(/:action(/:id))'
  post ':controller(/:action(/:id))'  
end
