class PressController < ApplicationController
  def index
    respond_to do |format|
      format.js {
        if params[:search]
          @press = Press.where("LOWER(name) LIKE ?", "%#{params[:search].downcase}%").order("name ASC")
        else
          @game_id = params[:game]
          @level = params[:lv]
          @view = params[:action]
          unless params[:search_list]
            @press = Press.order("name ASC").all
            render 'games/pop_up'
          else
            @prs = Press.new
            @press = Press.where("LOWER(name) LIKE ?", "%#{params[:search_list].downcase}%").order("name ASC")
            render 'refresh_list'
          end
        end
      }
    end
  end

  def edit_list
    params.each do |key, value|
      if key.include? "scl"
        id = key[3..-1]
        press = Press.find(id)
        press.update_attribute(:scale, value)
      end
      if key.include? "url"
        id = key[3..-1]
        press = Press.find(id)
        press.update_attribute(:url, value)
      end
    end
    @game = Game.find(params[:game_id])
    @element_id = 'scores_container'
    @helper = 'scores(@game)'
    respond_to do |format|
      format.js { render 'games/refresh_game' }
    end
  end
end
