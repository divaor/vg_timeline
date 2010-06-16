class AddTentativeTextToGames < ActiveRecord::Migration
  def self.up
    add_column :games, :tentative_date_text, :string
  end

  def self.down
    remove_column :games, :tentative_date_text
  end
end
