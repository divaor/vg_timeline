class AddScaleToPress < ActiveRecord::Migration
  def self.up
    add_column :press, :scale, :string
  end

  def self.down
    remove_column :press, :scale
  end
end
