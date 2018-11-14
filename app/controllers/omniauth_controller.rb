class OmniauthController < ApplicationController
	# skip_before_action :verify_authenticity_token

	def spotify
		current_user.spotify_data = request.env['omniauth.auth']
		current_user.save!
		redirect_to playlists_path
	end
end
