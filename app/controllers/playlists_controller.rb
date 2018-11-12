class PlaylistsController < ApplicationController
  before_action :authenticate_user!

  def index
    @playlists = Playlist.all
  end

  def show
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
            threshold: "0.5",
            owners: ["me"]
        )
    end

    watson_guesses = playlist_classes(@analysis)

    if @playlist.save
      redirect_to playlist_path(@playlist)
    else
      flash[:errors] = @playlist.errors.full_messages
      render :new
    end
  end

  private

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
  end
end


