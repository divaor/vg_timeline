class AddTentativeDateToGames < ActiveRecord::Migration
  def self.up
    add_column :games, :tentative_date, :boolean, :default => false, :null => false
  end

  def self.down
    remove_column :games, :tentative_date
  end
end
