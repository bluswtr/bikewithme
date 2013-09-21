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
#      resources :join, only: :update, :destroy
  end

  resources :events do
    collection do 
      get 'nearest'
    end
    put 'watch'
    put 'join'
  end

end