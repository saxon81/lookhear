class OmniauthController < ApplicationController
	# skip_before_action :verify_authenticity_token

	def spotify
		current_user.token = request.env['omniauth.auth']["credentials"]["token"]
		current_user.save!
		redirect_to 'playlist#index'
	end
end
