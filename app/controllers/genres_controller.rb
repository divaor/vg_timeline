class GenresController < ApplicationController
  def new
    @genre = Genre.new
    @game = Game.find(params[:game])
    @view = 'new'
    @level = params[:lv]
    respond_to do |format|
      format.js { render 'pop_up' }
    end
  end

  def create
    success = true
    genres = params[:genre][:name].split(',')
    for genre in genres
      if not Genre.create(:name => genre)
        success = false
      end
    end
    if success
      flash[:notice] = "Added genre(s) succesfully."
      redirect_to game_path(params[:game])
    else
      flash[:alert] = "Could not add one or more genre(s)."
      redirect_to game_path(params[:game])
    end
  end

end
