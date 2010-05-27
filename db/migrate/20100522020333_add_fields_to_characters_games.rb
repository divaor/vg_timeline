class AddFieldsToCharactersGames < ActiveRecord::Migration
  def self.up
    add_column :characters_games, :id, :primary_key
    add_column :characters_games, :playable, :boolean, :null => false, :default => true
  end

  def self.down
    remove_column :characters_games, :playable
    remove_column :characters_games, :id
  end
end
