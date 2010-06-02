class RenameTableIdToModifications < ActiveRecord::Migration
  def self.up
    rename_column :modifications, :table_id, :mod_table_id
  end

  def self.down
    rename_column :modifications, :mod_table_id, :table_id
  end
end
