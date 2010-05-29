class Modification < ActiveRecord::Base
  belongs_to :user
  belongs_to :mod_table
end
