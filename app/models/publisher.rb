class Publisher < ActiveRecord::Base
  has_and_belongs_to_many :games

  validates :name, :presence => true

  def result_display
    name
  end
end
