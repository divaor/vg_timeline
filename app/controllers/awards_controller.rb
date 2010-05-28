class AwardsController < ApplicationController
  def new
    @award = Award.new
    @level = params[:lv]
    @view = params[:action]
    @game = Game.find(params[:game])
    @award.game = @game
    respond_to do |format|
      format.js { render 'pop_up' }
    end
  end

  def create
    @award = Award.new(params[:award])
    if @award.save
      flash[:notice] = "Award added succesfully."
    else
      flash[:alert] = "Could not add award."
    end
    @element_id = "award_container"
    @helper = "awards(@game)"
    @game = @award.game
    respond_to do |format|
      format.js { render 'games/refresh_game' }
    end
  end

end
