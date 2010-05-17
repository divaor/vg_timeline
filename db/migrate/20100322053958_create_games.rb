class CreateGames < ActiveRecord::Migration
  def self.up
    create_table :games do |t|
      t.string :main_title, :null => false
      t.string :sub_title
      t.date :release_date, :null => false
      t.integer :platform_id, :null => false
      t.string :boxart
      t.integer :game_type_id, :null => false

      t.timestamps
    end
  end

  def self.down
    drop_table :games
  end
end
