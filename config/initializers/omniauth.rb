Rails.application.config.middleware.use OmniAuth::Builder do
  provider :spotify, 
  	Rails.application.credentials.spotify[:client_id],
  	Rails.application.credentials.spotify[:client_secret],
  	scope: %w(
	    playlist-read-private
	    playlist-modify-public
	    playlist-modify-private
	  ).join(' ')
end