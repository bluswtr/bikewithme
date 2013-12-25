require 'sidekiq/web'

Rails3MongoidDevise::Application.routes.draw do
  devise_for :users, :controllers => { 
    :omniauth_callbacks => "users/omniauth_callbacks",
    :sessions => "sessions"
  }

  authenticated :user do
    root :to => 'events#landing'
  end
  
  root :to => "events#landing"
  devise_for :users
  resources :users do
      get 'followers'
      get 'following'
      get 'my_watches'
      get 'my_joins'
      get 'find_friends'
      resources :follow, only: [:destroy, :create]
      collection do
        get 'friends'
      end
  end

  resources :events do
    collection do 
      get 'nearest'
      get 'more_info/:event_id', to: 'events#more_info'
      get 'next_seven_days'
      get 'nearest_friends'
      get 'nearest_all'
    end
    resources :invite, only: [:create, :new] do
      collection do
        get 'not_yet_invited'
        get 'invited'
        get 'invitation/:contact_id', to: 'invite#invitation'
      end
    end
    resources :watch, only: [:destroy, :create]
    resources :join, only: [:destroy, :create]
  end

  mount Sidekiq::Web, at: '/sidekiq'

end