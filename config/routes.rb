Rails3MongoidDevise::Application.routes.draw do
  devise_for :users, :controllers => { :omniauth_callbacks => "users/omniauth_callbacks" }

  authenticated :user do
    root :to => 'events#index'
  end
  
  root :to => "events#index"
  devise_for :users
  resources :users do
      get 'followers'
      get 'following'
      resources :follow, only: :update
      resources :unfollow, only: :update
  end

  resources :events do
    collection do 
      get 'nearest'
    end
    resources :watch, only: :update
    put 'join'
  end

end