class AddSpotifyDataToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :spotify_data, :json
  end
end
