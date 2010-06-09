class PlatformsController < ApplicationController

  def index
    #@platforms = Platform.where("LOWER(name) LIKE ?", "%#{params[:search].downcase}%").limit(10)
    respond_to do |format|
      format.js {
        if params[:search]
          @platforms = Platform.where("LOWER(name) LIKE ?", "%#{params[:search].downcase}%").limit(10)
        else
          @year = '2010'
          @div = 'plat_filters'
          @all = 'y_plat_all'
          @extra = ''
          items = items_year('platforms', @year)
          @filtered_items = Platform.where("id in (#{items}) and LOWER(name) LIKE ?", "%#{params[:search_list].downcase}%").order("name ASC")
          render 'games/refresh_filter'
        end
      }
    end
  end
end
