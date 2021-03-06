class CharactersGamesController < ApplicationController

  def new
    @characters_game = CharactersGame.new
    @level = params[:lv]
    @view = params[:action]
    @characters_game.game_id = params[:game]
    respond_to do |format|
      format.js { render 'games/pop_up' }
    end
  end

  def create
    @character = Character.find_by_name(params[:characters_game][:character_name])
    if @character
      @characters_game = CharactersGame.where("game_id = ? AND character_id = ?", params[:characters_game][:game_id], @character.id).first
      if @characters_game
        @characters_game.update_attributes(params[:characters_game])
      else
        @characters_game = CharactersGame.new(params[:characters_game])
        @characters_game.save
      end
    else
      @characters_game = CharactersGame.new(params[:characters_game])
      @characters_game.save
    end
    for game in @characters_game.game.different_platforms
      CharactersGame.create(:game_id => game.id, :character_id => @characters_game.character_id, :playable => @characters_game.playable) unless game.characters.include?(@characters_game.character)
    end
    @characters_game.character.update_attributes(params[:character]) if params[:character]
    @series_games_characters = @characters_game.in_series_games || []
    @characters_list = @characters_game.game.get_characters_type
    respond_to do |format|
      format.js
      format.html { redirect_to game_path(params[:characters_game][:game_id]) }
    end
  end
end
