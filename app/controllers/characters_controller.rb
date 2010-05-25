class CharactersController < ApplicationController


  def index
    if params[:search]
      @characters = Character.where("LOWER(name) LIKE ?", "%#{params[:search].downcase}%")
      @search = params[:search]
      respond_to do |format|
        format.js
      end
    else
      @characters = Character.all
      @characters.sort! { |a, b| b.games.count <=> a.games.count }
      @level = params[:lv]
      @view = params[:action]
      respond_to do |format|
        format.js { render 'pop_up' }
      end
    end
  end

  def show
    @character = Character.find(params[:id])
    @level = params[:lv]
    @view = params[:action]
    respond_to do |format|
      format.js { render 'pop_up' }
    end
  end

  def new
    @character = Character.new
    @level = params[:lv]
    @view = params[:action]
    @game = Game.find(params[:game])
    @character.game = @game.id
    respond_to do |format|
      format.js { render 'pop_up' }
    end
  end

  def create
    @character = Character.find_by_name(params[:character][:name])
    if @character
      @character.update_attribute(:game, params[:character][:game])
    else
      @character = Character.new(params[:character])
      if @character.save
        flash[:notice] = "Character added succesfully."
      else
        flash[:alert] = "Could not add character."
      end
    end
    redirect_to game_path(params[:character][:game])
  end

end
