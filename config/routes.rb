Rails3MongoidDevise::Application.routes.draw do
  devise_for :users, :controllers => { :omniauth_callbacks => "users/omniauth_callbacks" }

  authenticated :user do
    root :to => 'events#landing'
  end
  
  root :to => "events#index"
  devise_for :users
  resources :users do
      get 'followers'
      get 'following'
      get 'my_watches'
      get 'my_joins'
      resources :follow, only: [:destroy, :create]
      #resources :events, only: [:index]
      #resources :follow, only: :update
      #resources :unfollow, only: :update
  end

  resources :events do
    collection do 
      get 'nearest'
      get 'more_info/:event_id', to: 'events#more_info'
    end
    resources :watch, only: [:destroy, :create]
    resources :join, only: [:destroy, :create]
  end

end