class PlaylistController < ApplicationController
	def index
		@playlist = Playlist.all
	end
end
