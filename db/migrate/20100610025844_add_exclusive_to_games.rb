class AddExclusiveToGames < ActiveRecord::Migration
  def self.up
    add_column :games, :exclusive, :boolean, :null => false, :default => false
  end

  def self.down
    remove_column :games, :exclusive
  end
end
