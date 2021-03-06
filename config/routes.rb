Rails.application.routes.draw do
  devise_for :users, controllers: {
    registrations: 'users/registrations'
    }
    devise_scope :user do
      get 'addresses', to: 'users/registrations#new_address'
      post 'addresses', to: 'users/registrations#create_address'
      get 'creditcards', to: 'users/registrations#new_creditcard'
      post 'creditcards', to: 'users/registrations#create_creditcard'
    end
  root 'items#index'

  resources :items do 
    collection do
      get 'category/get_category_children', to: 'items#get_category_children', defaults: { format: 'json' }
      get 'category/get_category_grandchildren', to: 'items#get_category_grandchildren', defaults: { format: 'json' }
    end
    
    member do
      get 'purchase_confirm'
      post 'purchase'
    end
  end

  resources :users, only: [] do
    collection do
      get 'mypage'
      get 'identification'
      get 'logout'
      resources :credit_cards, only:[:new, :show, :create, :destroy]
      resources :addresses, only:[:new, :edit, :create, :update, :destroy]
    end
  end
end
