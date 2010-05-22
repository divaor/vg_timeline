class CharactersGamesController < ApplicationController

  def new
    @characters_game = CharactersGame.new
    @level = params[:lv]
    @view = params[:action]
    @characters_game.game_id = params[:game]
    respond_to do |format|
      format.js { render 'pop_up' }
    end
  end

  def create
    @character = Character.find_by_name(params[:characters_game][:character_name])
    if @character
      @characters_game = CharactersGame.where("game_id = ? AND character_id = ?", params[:characters_game][:game_id], @character.id).first
      if @characters_game
        @characters_game.update_attributes(params[:characters_game])
        redirect_to game_path(params[:characters_game][:game_id])
        return
      end
    end
    @characters_game = CharactersGame.new(params[:characters_game])
    if @characters_game.save
      @characters_game.character.update_attributes(params[:character]) if params[:character]
      flash[:notice] = "Character added succesfully."
    else
      flash[:alert] = "Could not add character."
    end
    redirect_to game_path(params[:characters_game][:game_id])
  end

end
