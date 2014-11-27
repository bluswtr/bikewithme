require 'sidekiq/web'

Rails3MongoidDevise::Application.routes.draw do
  devise_for :users, :controllers => { 
    :omniauth_callbacks => "users/omniauth_callbacks",
    :sessions => "sessions"
  }

  authenticated :user do
    root :to => 'events#home'
  end
  
  root :to => "events#home"
  devise_for :users
  resources :users do
      get 'followers'
      get 'following'
      get 'my_watches'
      get 'my_joins'
      get 'find_friends'
      get 'status_feed'
      get 'my_activity'
      get 'invitation'
      resources :follow, only: [:destroy, :create]
      resources :microposts, only: [:create, :destroy, :show]
      collection do
        get 'friends'
      end
  end

  resources :events do
    collection do 
      get 'nearest_json'
      get 'more_info/:event_id', to: 'events#more_info'
      get 'next_seven_days'
      get 'nearest_friends'
      get 'nearest_all'
      get 'home'
      get 'landing'
      post 'save_geolocation'
      post 'save_timezone_offset'
      post 'geolocation_search'
      get 'past_rides'
      get 'active_rides'
      get 'drafts'
      get 'watchlist'
      get 'invitation'
      resources :eventpost do
        get 'details'
        put 'update_details'
      end
      resources :eventsearch, only: [:create, :new, :show, :index]
    end
    resources :watch, only: [:create]
    resources :unwatch, only: [:create]
    resources :join, only: [:create]
    resources :unjoin, only: [:create]
  end

    resources :invite, only: [:create, :new] do
      collection do
        get 'guestlist_all'
        get 'guestlist_bwm'
        get 'guestlist_outsiders'
        get 'to_app'
        get 'to_event'
        get 'outsider_to_event'
      end
    end
  mount Sidekiq::Web, at: '/sidekiq'

end