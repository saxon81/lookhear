require 'httparty'
require 'rspotify'

class PlaylistsController < ApplicationController
  before_action :authenticate_user!

  def index
    @playlists = Playlist.all
  end

  def edit
    @playlist = Playlist.find(params[:id])
    @lyrics = params[:lyrics]
    @results = fetch_songs_by_lyrics(params[:lyrics])
  end

  def show
    @playlist = Playlist.find(params[:id])
    spotify_user = RSpotify::User.new(current_user.spotify_data)

    RSpotify.authenticate(Rails.application.credentials.spotify[:client_id], Rails.application.credentials.spotify[:client_secret])
    playlist = RSpotify::Playlist.find(spotify_user.id, @playlist.spotify_id)
    @playlist_url = playlist.external_urls["spotify"]
    @playlist_image = playlist.images.first ? playlist.images.first["url"] : ""
  end

  def add_song
    @playlist = Playlist.find(params[:id])
    spotify_user = RSpotify::User.new(current_user.spotify_data)

    RSpotify.authenticate(Rails.application.credentials.spotify[:client_id], Rails.application.credentials.spotify[:client_secret])
    playlist = RSpotify::Playlist.find(spotify_user.id, @playlist.spotify_id)
    tracks = RSpotify::Track.search("#{params[:artist_name]} #{params[:track_name]}")
    playlist.add_tracks!([tracks[0]])

    redirect_to playlist_path
  end

  def new
    @playlist = Playlist.new
    @user = current_user
  end

  def create
    @playlist = Playlist.new
    @playlist.photo.attach(params[:playlist][:photo])
    @playlist.user = current_user


    visual_recognition = IBMWatson::VisualRecognitionV3.new(
    version: ENV["WATSON_VERSION"],
    iam_apikey: ENV["WATSON_APIKEY"]
    )

    File.open(params[:playlist][:photo].tempfile.path) do |photo|
        @analysis = visual_recognition.classify(
            images_file: photo,
            threshold: "0.15",
            owners: ["me"]
        )
    end

    spotify_user = RSpotify::User.new(current_user.spotify_data)
    playlist = spotify_user.create_playlist!('LookHear Presents: ' + playlist_classes(@analysis).titleize.split(' ').to_sentence)
    @playlist.spotify_id = playlist.id
    if @playlist.save
      redirect_to edit_playlist_path(@playlist, lyrics: playlist_classes(@analysis))
    else
      flash[:errors] = @playlist.errors.full_messages
      render :new
    end
  end

private

  def fetch_songs_by_lyrics(lyrics)
    # url = "https://api.musixmatch.com/ws/1.1/matcher.lyrics.get?format=jsonp&callback=callback&apikey=d454fab236974eb8518f5ae0fe594cf9"
    url = "http://api.musixmatch.com/ws/1.1/track.search?q_lyrics=#{lyrics}&page_size=5&page=1&s_track_rating=desc&apikey=d454fab236974eb8518f5ae0fe594cf9"
    response = JSON.parse(HTTParty.get(url).body)
    response["message"]["body"]["track_list"].map do |track| 
      {
        track_name: track["track"]["track_name"],
        artist_name: track["track"]["artist_name"]
      }
    end
  end

  def playlist_params
    params.require(:playlist).permit(:photo)
  end

  def playlist_classes(analysis)
    analysis
      .result["images"]
      .first["classifiers"]
      .pluck("classes")
      .flatten
      .pluck("class")
      .map { |klass| klass.gsub("cowboy20", "cowboy") }
      .join(" ")
  end
end


