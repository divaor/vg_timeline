class CreateCharactersGamesTable < ActiveRecord::Migration
  def self.up
    create_table :characters_games, :id => false do |t|
      t.integer :character_id
      t.integer :game_id
    end
  end

  def self.down
    drop_table :characters_games
  end
end
