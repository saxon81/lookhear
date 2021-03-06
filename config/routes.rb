Rails.application.routes.draw do
	root to: "playlists#index"

	resources :playlists do
		member do
			get "add_song"
		end
	end
  	devise_for :users

  	get '/auth/spotify/callback', to: 'omniauth#spotify'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
