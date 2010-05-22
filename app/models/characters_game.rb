class CharactersGame < ActiveRecord::Base

  belongs_to :game
  belongs_to :character

  def character_name
    character.name if character
  end

  def character_name=(name)
    self.character = Character.find_or_create_by_name(name) unless name.blank?
  end
end
