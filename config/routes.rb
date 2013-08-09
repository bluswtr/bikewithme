Rails3MongoidDevise::Application.routes.draw do
  devise_for :users, :controllers => { :omniauth_callbacks => "users/omniauth_callbacks" }

  authenticated :user do
    root :to => 'events#show'
  end
  root :to => "events#show"
  devise_for :users
  resources :users do
    collection do
      get 'followers'
      get 'following'
      get 'follow'
    end
  end
  # resources :events, :id => /.*/ do
  # 	member do
  # 		post 'nearest'
  # 	end
  # end
  resources :events do
    collection do 
      get 'nearest'
      get 'test'
    end
  end

  #new_event_path :events/new
end