class CreateVideos < ActiveRecord::Migration
  def self.up
    create_table :videos do |t|
      t.string :file_name, :null => false
      t.integer :game_id, :null => false

      t.timestamps
    end
  end

  def self.down
    drop_table :videos
  end
end
