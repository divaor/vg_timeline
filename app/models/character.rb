class Character < ActiveRecord::Base
  include Paperclip
  
  has_many :characters_games
  has_many :games, :through => :characters_games

  has_attached_file :picture, :storage => :s3, :s3_credentials => "#{Rails.root}/config/s3.yml", :url => "/images/characters/:style/:character_picture", :styles => { :medium => "400x400>", :thumb => "120x120>", :mini => "50x50>" }, :path => "/images/characters/:style/:character_picture"

  def game
    games.last.id
  end

  def game=(game_id)
    gm = Game.find(game_id) unless game_id.blank?
    self.games << gm unless games.include?(gm)
  end

  def games_of_character
    games_titles = []
    games = []
    for game in self.games
      unless games_titles.include?(game.full_title)
        games_titles << game.full_title
        games << game
      end
    end

    return games
  end
end
