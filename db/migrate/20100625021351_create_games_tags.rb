class CreateGamesTags < ActiveRecord::Migration
  def self.up
    create_table :games_tags, :id => false do |t|
      t.integer :game_id
      t.integer :tag_id
    end
  end

  def self.down
    drop_table :games_tags
  end
end
