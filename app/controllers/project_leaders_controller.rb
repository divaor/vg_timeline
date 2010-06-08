class ProjectLeadersController < ApplicationController
  
  def new
    @project_leader = ProjectLeader.new
    @level = params[:lv]
    @view = params[:action]
    @game = Game.find(params[:game])
    @project_leader.game_id = @game.id
    respond_to do |format|
      format.js { render 'games/pop_up' }
    end
  end

  def create
    @project_leader = ProjectLeader.new(params[:project_leader])
    if @project_leader.save
      flash[:notice] = "Industry person added succesfully."
    else
      flash[:alert] = "Could not add industry person."
    end
    @element_id = "key_people"
    @helper = "key_people(@game)"
    @game = @project_leader.game
    respond_to do |format|
      format.js { render 'games/refresh_game' }
    end
  end
end
