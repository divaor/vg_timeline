class RatingsController < ApplicationController
  def index
    if params[:search_list]
      @year = '2010'
      @div = 'rat_filters'
      @all = 'y_rat_all'
      @extra = 'r'
      @filtered_items = Rating.where("LOWER(name) LIKE ?", "%#{params[:search_list].downcase}%").order("name ASC")
      respond_to do |format|
        format.js { render 'games/refresh_filter' }
      end
    end
  end
end
