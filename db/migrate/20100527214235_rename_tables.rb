class RenameTables < ActiveRecord::Migration
  def self.up
    rename_table(:tables, :mod_tables)
  end
end
