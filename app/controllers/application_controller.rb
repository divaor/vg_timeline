class ApplicationController < ActionController::Base
  protect_from_forgery

  def pop_up
    @level = params[:level]
    @file = params[:file]
    @title = "Add New Game"
    @game = Game.new
    @date = (params[:year] && params[:month]) ? Date.parse("#{params[:year]}-#{params[:month]}-01") : Date.today
    @platforms = Platform.all
    @developers = Developer.order("name asc").all
    @publishers = Publisher.order("name asc").all
    hsh = { 'key' => 'value', 'key2' => 'value2' }
    print hsh['key']
    respond_to do |format|
      format.js { render 'pop_up' }
    end
  end

  def close_pop
    @level = params[:level]
    respond_to do |format|
      format.js
    end
  end

  def search
    @results = []
    @search = params[:search]
    @games = search_box_results(:game, params[:search], :field => 'main_title')
    @characters = search_box_results(:character, params[:search])
    @developers = search_box_results(:developer, params[:search])
    @publishers = search_box_results(:publisher, params[:search])
    @games.each { |g| @results << g }
    @characters.each { |c| @results << c }
    @developers.each { |d| @results << d }
    @publishers.each { |p| @results << p }
    respond_to do |format|
      format.js { render 'layouts/search' }
    end
  end

  def search_results
    if params[:result_id] != 'none'
      values = params[:result_id].split('_', 2)
      model = values[0]
      id = values[1]
      @result = eval("#{model}.find(#{id})")
    else
      title = params[:result][:text].split(':')
      title[1] = "" unless title[1]
      @result = Game.where("LOWER(main_title) LIKE ? AND LOWER(sub_title) = ?", "%#{title[0].downcase.strip}%", title[1].downcase.strip).first
      unless @result
        @result = Game.where("LOWER(sub_title) LIKE ?", "%#{title[0].downcase.strip}%").first
      end
      model = 'game'
    end
    if @result
      redirect_to eval("#{model.downcase}_path(@result)")
    else
      flash[:alert] = "Game not found."
      redirect_to year_path(Date.today.year)
    end
  end

  private

  def create_log_entry(table, id, description, parameters)
    parameters = { :add => false, :mod => false, :remove => false }.merge(parameters)
    table = ModTable.where("name = ?", table).first
    log = Modification.new(:user => current_user, :mod_table => table, :modified_id => id, :description => description,
      :added => parameters[:add], :modified => parameters[:mod], :removed => parameters[:remove])
    log.save
  end

  def experience_user(new_exp)
    current_user.update_attribute('exp', current_user.exp += new_exp)
    if current_user.exp >= current_user.level.exp_next_level and current_user.level.exp_next_level > 0
      next_level = Level.where("level = ?", current_user.level.level + 1).first
      current_user.update_attribute('level', next_level)
      " You've advanced to level #{current_user.level.level}. Congratulations."
    else
      " +#{new_exp} Exp. points."
    end
  end

  def month_name(month_number)
    if month_number == 1
      return "January"
    elsif month_number == 2
      return "February"
    elsif month_number == 3
      return "March"
    elsif month_number == 4
      return "April"
    elsif month_number == 5
      return "May"
    elsif month_number == 6
      return "June"
    elsif month_number == 7
      return "July"
    elsif month_number == 8
      return "August"
    elsif month_number == 9
      return "September"
    elsif month_number == 10
      return "October"
    elsif month_number == 11
      return "November"
    elsif month_number == 12
      return "December"
    end
  end

  def first_week_sunday(month, year)
    date = Date.parse("#{year}-#{month}-01")
    return date if date.strftime("%A") == "Sunday"
    1.days.ago(date.monday)
  end

  def last_day_month(month, year)
    date = Date.parse("#{year}-#{month}-#{Time.days_in_month(month.to_i, year.to_i)}")
    while date.strftime("%A") != "Saturday"
      date = 1.days.since(date)
    end
    date
  end

  # Searches records of model that contain find in options[:field](default 'name')
  def search_box_results(model, find, options = {})
    options = { :field => 'name' }.merge(options)
    model = model.to_s.camelize.constantize
    field = options[:field]
    result = []; master_result = []
    result[0] = model.where("LOWER(#{field}) = ?", find.downcase).order("#{field} ASC").all
    result[1] = model.where("LOWER(#{field}) LIKE ?", "#{find.downcase}%").order("#{field} ASC").all
    result[2] = model.where("LOWER(#{field}) LIKE ?", "%#{find.downcase}").order("#{field} ASC").all
    result[3] = model.where("LOWER(#{field}) LIKE ?", "%#{find.downcase}%").order("#{field} ASC").all
    result.each do |r|
      r.each do |r2|
        master_result << r2 unless master_result.length >= 5 or master_result.include?(r2)
      end
    end
    master_result
  end
end
