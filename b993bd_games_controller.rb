class GamesController < ApplicationController
  #caches_page :index

  Limit = 0

  def index
    if params[:search]
      @games = Game.where("LOWER(main_title) LIKE ? OR LOWER(sub_title) LIKE ?", "%#{params[:search].downcase}%", "%#{params[:search].downcase}%").limit(14)
      @search = params[:search]
      respond_to do |format|
        format.js
      end
    else
      @game = Game.new
      @year = params[:year] ? params[:year].to_i : Date.today.year
      @title = @year
      @id = params[:game_id] if params[:game_id]
      @enter_year = true
      @games = Game.where('release_date >= ? and release_date <= ?', "#{@year}-01-01", "#{@year}-12-31").order("release_date asc, hits desc, main_title asc").all
      @stats = get_stats(@games)
      @platforms = Platform.order("name asc")
      @publishers = Publisher.order("name asc")
      @developers = Developer.order("name asc")
      if not @games.empty?
        games = make_games_array(@games, Limit, true)
        @months = games['games']
        @platforms_month = games['platforms']
        @platforms_year = games['platforms_year']
        @genres = Genre.all
        @ratings = Rating.all
      end
    end
  end

  def month_view
    @year = params[:year] ? params[:year].to_i : Date.today.year
    @month = params[:month] ? params[:month] : Date.today.month
    @month = "0"+@month.to_s if @month.length == 1
    @real_month = @month
    @title = month_name(@month.to_i) + " " + @year.to_s
    @enter_year = true
    first_day = first_week_sunday(@month, @year)
    last_day = last_day_month(@month, @year)
    @games = Game.where('release_date >= ? and release_date <= ?', "#{first_day.year}-#{first_day.month}-#{first_day.day}", "#{last_day.year}-#{last_day.month}-#{last_day.day}").order("release_date asc, hits desc, main_title asc").all
    #if not @games.empty?
    @stats = get_stats(@games)
    games = games_array_weeks(@games, @month, @year)
    @weeks = games['games']
    @platforms_month = games['platforms']
    @platforms_year = games['platforms_month']
    #end
  end

  def other_year
    @game = Game.new
    @year = params[:year] ? params[:year].to_i : Date.today.year;
    @id = params[:game_id] if params[:game_id]
    @enter_year = true
    @games = Game.where('release_date >= ? and release_date <= ?', "#{@year}-01-01", "#{@year}-12-31").order("release_date asc, hits desc, main_title asc").all
    if not @games.empty?
      flash.discard(:notice)
      games = make_games_array(@games, Limit, true)
      @months = games['games']
      @platforms_month = games['platforms']
      @platforms_year = games['platforms_year']
    end
    respond_to do |format|
      format.js
    end
  end

  def list
    @level = params[:lv]
    @view = params[:action]
    @games = Game.order("main_title asc")
    respond_to do |format|
      format.js { render 'pop_up' }
    end
  end

  def recent
    @level = params[:lv]
    @view = params[:action]
    @games = Game.order("created_at desc").limit(20)
    respond_to do |format|
      format.js { render 'pop_up' }
    end
  end

  def order_games_list
    @games = Game.order("#{params[:order]} asc")
    if params[:order] == "platform_id"
      @games = @games.sort { |a, b| a.platform.name <=> b.platform.name }
    end
    respond_to do |format|
      format.js
    end
  end

  def show
    @game = Game.find(params[:id])
    @game.update_attribute('hits', @game.hits += 1)
    @characters = @game.get_characters_type
    @series_games = @game.series_list_by_full_title
    @title = @game.full_title_limit
  end

  def new
    @level = params[:lv] + "&"
    index = @level.index("month")
    @month = @level.slice(@level.index("=", index) + 1, @level.index("&", index) - @level.index("=", index) - 1) if index
    index = @level.index("year")
    @year = @level.slice(@level.index("=", index) + 1, @level.index("&", index) - @level.index("=", index) - 1) if index
    index = @level.index("id_diff")
    id_diff = @level.slice(@level.index("=", index) + 1, @level.index("&", index) - @level.index("=", index) - 1) if index
    index = @level.index("series")
    series_id = @level.slice(@level.index("=", index) + 1, @level.index("&", index) - @level.index("=", index) - 1) if index
    @level = @level.slice(0,1) if @level.length > 1
    @view = params[:action]
    @title = "Add New Game"
    if id_diff
      game_diff = Game.find(id_diff)
      attributes = { :main_title => game_diff.main_title, :sub_title => game_diff.sub_title, :release_date => game_diff.release_date }
      @view = "new_lite"
      @diff_platform_id = game_diff.id
    elsif series_id
      series = Series.find(series_id)
      attributes = { :main_title => series.name, :series_id => series.id }
    end
    @game = attributes ? Game.new(attributes) : Game.new
    @game.publisher_names = game_diff.publisher_names if game_diff
    @date = (@year && @month) ? Date.parse("#{@year}-#{@month}-01") : Date.today
    @platforms = Platform.all
    @markets = Market.all
    rating_system = RatingSystem.where("market_id = ?", @markets.first.id).first
    @ratings = Rating.where("rating_system_id = ?", rating_system.id).order("name asc")
    @developers = Developer.order("name asc").all
    @publishers = Publisher.order("name asc").all
    respond_to do |format|
      format.js { render 'pop_up' }
    end
  end

  def new_game_add_developer
    @developers = Developer.order("name asc").all
    respond_to do |format|
      format.js
    end
  end

  def new_game_add_publisher
    @publishers = Publisher.order("name asc").all
    respond_to do |format|
      format.js
    end
  end

  def create # TODO have different platforms be assigned in model instead of controller
    platform = Platform.find_by_name(params[:game][:platform_name])
    @game_exists = Game.where("main_title = ? and sub_title = ? and platform_id = ?", params[:game][:main_title], params[:game][:sub_title], platform.id).first if platform
    @game_diff = Game.find(params[:diff_platform_id]) if params[:diff_platform_id]
    if @game_exists and @game_diff
      for game in @game_exists.different_platforms
        game.different_platforms << @game_diff unless game.different_platforms.exists?(@game_diff) or game == @game_diff
        @game_diff.different_platforms << game unless @game_diff.different_platforms.exists?(game) or @game_diff == game
      end
      for game2 in @game_diff.different_platforms
        game2.different_platforms << @game_exists unless game2.different_platforms.exists?(@game_exists) or game2 == @game_exists
        @game_exists.different_platforms << game2 unless @game_exists.different_platforms.exists?(game2) or @game_exists == game2
        for game3 in @game_exists.different_platforms
          game2.different_platforms << game3 unless game2.different_platforms.exists?(game3) or game2 == game3
          game3.different_platforms << game2 unless game3.different_platforms.exists?(game2) or game3 == game2
        end
      end
      @game_exists.different_platforms << @game_diff unless @game_exists.different_platforms.exists?(@game_diff) or @game_exists == @game_diff
      @game_diff.different_platforms << @game_exists unless @game_diff.different_platforms.exists?(@game_exists) or @game_diff == @game_exists
      flash[:notice] = "Games linked succesfully."
      redirect_to game_path(@game_exists)
    elsif @game_exists and not @game_diff
      flash[:alert] = "Game already exists."
      redirect_to game_path(@game_exists)
    else
      @game = Game.new(params[:game])
      if @game_diff
        @game.market = @game_diff.market
        @game.description = @game_diff.description
        @game.series = @game_diff.series
        @game.spinoff = @game_diff.spinoff
        @game.rating = @game_diff.rating
        @game.local_players = @game_diff.local_players
        @game.online_players = @game_diff.online_players
        @game.local_multi_modes = @game_diff.local_multi_modes
        @game.online_multi_modes = @game_diff.online_multi_modes
        @game.developers = @game_diff.developers
        @game.features = @game_diff.features
        @game.genres = @game_diff.genres
        @game.publishers = @game_diff.publishers
        @game.specifications = @game_diff.specifications
        @game.types = @game_diff.types
        @game.project_leaders = @game_diff.project_leaders
        @game.characters = @game_diff.characters
        @game.different_platforms << @game_diff
        for game1 in @game_diff.different_platforms
          @game.different_platforms << game1 unless @game.different_platforms.exists?(game1) or game1 == @game
        end
      end
      if @game.tentative_date
        @game.tentative_release_date = params[:date][:tentative]
      end
      @developers = []; @publishers = []
      if @game.save
        @game.prequel.update_attribute(:sequel, @game) if @game.prequel
        @game.sequel.update_attribute(:prequel, @game) if @game.sequel
        create_log_entry('games', @game.id, "Added game #{@game.full_title_limit}", :add => true)
        if @game_diff
          @game_diff.different_platforms << @game
          for game4 in @game_diff.different_platforms
            game4.different_platforms << @game unless (game4.different_platforms.exists?(@game) or game4 == @game)
          end
        end
        add_flash = experience_user(10)
        respond_to do |format|
          format.js {
            if params[:diff_platform_id]
              @element_id = 'diff_platforms_container'
              @game_eval = @game_diff ? '@game_diff' : '@game'
              @helper = "also_on(#{@game_eval})"
            end
            render 'refresh_game'
          }
          format.html {
            flash[:notice] = "Game succesfully created." + add_flash
            redirect_to game_path(@game)
          }
        end
      else
        flash[:alert] = "Could not complete request."
        @title = "Add New Game"
        @platforms = Platform.all
        @developers = Developer.order("name asc").all
        @publishers = Publisher.order("name asc").all
        @markets = Market.all
        @ratings = Rating.all
        render :template => 'games/_new', :layout => 'application'
      end
    end
  end

  def edit
    @level = params[:lv] + "&"
    index = @level.index("id")
    id = @level.slice(@level.index("=", index) + 1, @level.index("&", index) - @level.index("=", index) - 1) if index
    index = @level.index("view")
    view = @level.slice(@level.index("=", index) + 1, @level.index("&", index) - @level.index("=", index) - 1) if index
    index = @level.index("element_id")
    @element_id = @level.slice(@level.index("=", index) + 1, @level.index("&", index) - @level.index("=", index) - 1) if index
    index = @level.index("eval")
    @helper = @level.slice(@level.index("=", index) + 1, @level.index("&", index) - @level.index("=", index) - 1) if index
    @level = @level.slice(0,1) if @level.length > 1
    @view = view ? view : params[:action]
    @title = "Edit Game"
    @game = Game.find(id)
    @date = @game.release_date
    @markets = Market.all
    rating_system = RatingSystem.where("market_id = ?", @markets.first.id).first
    @ratings = Rating.where("rating_system_id = ?", rating_system.id).order("name asc")
    @platforms = Platform.all
    @developers = Developer.order("name asc").all
    @publishers = Publisher.order("name asc").all
    @multi_modes = MultiplayerMode.all
    @types = Type.all
    @genres = Genre.all
    @characters = @game.characters
    respond_to do |format|
      format.js { render :action => 'pop_up' }
    end
  end

  def update
    @game = Game.find(params[:id])
    old_game_info = { :year => @game.r_y, :month => @game.r_m, :path => @game.make_boxart_path }
    if @game.update_attributes(params[:game]) # TODO if no params[:game] is passed it throws error
      if (params[:game][:prequel_name] or params[:game][:sequel_name]) and not @game.sequel and not @game.prequel
        unless params[:game][:sequel_name].empty?
          pre_seq = params[:game][:sequel_name]
          update = :prequel_name
          with = @game.full_title_colon
          series_id = @game.series_id
        end
        unless params[:game][:prequel_name].empty? and pre_seq
          pre_seq = params[:game][:prequel_name]
          update = :sequel_name
          with = @game.full_title_colon
          series_id = @game.series_id
        end
        @game = Game.new(:full_title_colon => pre_seq, update => with, :series_id => series_id)
        @title = "Add New Game"
        @markets = Market.all
        @platforms = Platform.all
        @developers = Developer.order("name asc").all
        @publishers = Publisher.order("name asc").all
        @ratings = Rating.all
        flash[:notice] = "Game not found, fill in form to add game"
        render :template => 'games/_new', :layout => 'application'
        return
      end
      create_log_entry('games', @game.id, "Modified game #{@game.full_title_limit}", :mod => true)
      for game in @game.different_platforms
        create_log_entry('games', @game.id, "Modified #{@game.full_title_limit}", :mod => true)
        game.update_attribute('series_id', @game.series_id)
      end
      move_boxart(old_game_info, @game)
      if params[:character]
        character = Character.find_by_name(params[:game][:character_name])
        character.update_attributes(params[:character])
      end
      if @game.tentative_date
        @game.tentative_release_date = params[:date][:tentative]
      end
      add_flash = experience_user(5)
      flash[:notice] = "Game succesfully updated." + add_flash
      respond_to do |format|
        format.js {
          @element_id = params[:element_id]
          @helper = params[:helper] + "(@game)"
          render 'refresh_game'
        }
        format.html { redirect_to game_path(@game) }
      end
    else
      @title = "Add New Game"
      @platforms = Platform.all
      @developers = Developer.order("name asc").all
      @publishers = Publisher.order("name asc").all
      render :partial => 'edit', :layout => 'application'
    end
  end

  def add_to_games
    params.each do |key, value|
      if key.to_i > 0
        if value[:appears] == '1'
          @characters_game = CharactersGame.new(
            :character_id => params[:character], :game_id => key,
            :playable => value[:playable]
          )
          @characters_game.save
        end
      end
    end
  end

  def show_game_info
    @game = Game.find(params[:id])
    x_coord = params[:xcoord]
    if x_coord.to_i > 0
      @right = true
    else
      @right = false
    end
    @game.update_attribute('hits', @game.hits += 1)
    @div_id = "game#{params[:id]}"
    @scores = @game.scores
    respond_to do |format|
      format.js
    end
  end

  def show_game_tooltip
    @game_info = Game.find(params[:id])
    @pos = params[:pos]
    respond_to do |format|
      format.js
    end
  end

  def update_year
    @year = params[:y]; @ignore_months = []
    params.each_pair { |key,value|
      if key[0,2] == "ig"
        @ignore_months << value
      end
    }
    @games = search_games_by_checked_platforms(params)
    @stats = get_stats(@games)
    @applied_filters = []; platforms = ["Platforms"]; publishers = ["Publishers"]; developers = ["Developers"];
    ratings = ["Ratings"]; genres = ["Genres"]
    params.each_pair { |key, value|
      if key.to_i > 0 and value.to_i > 0
        platforms << Platform.find(value)
      elsif value[0,1] == 'p'
        publishers << Publisher.find(value.delete('p').to_i)
      elsif value[0,1] == 'd'
        developers << Developer.find(value.delete('d').to_i)
      elsif value[0,1] == 'n'
        genres << Genre.find(value.delete('n').to_i)
      elsif value[0,1] == 'r'
        ratings << Rating.find(value.delete('r').to_i)
      end
    }
    @applied_filters = [platforms,publishers,developers,genres,ratings]
    if @applied_filters == [["Platforms"],["Publishers"],["Developers"],["Genres"],["Ratings"]]
      @filtered = false
    else
      @filtered = true
    end
    if @games.empty?
      @months = []
      @no_games = ['01', '02', '03', '04', '05', '06', '07', '08', '09', '10', '11', '12']
    else
      games = make_games_array(@games, params[:l].to_i, true)
      @months = games['games']
      @no_games = games['no_games']
    end
    @limit = params[:l].to_i
    respond_to do |format|
      format.js
    end
  end

  def update_month
    if params[:w] then params[:m] = params[:w][0,2].to_i.to_s; @m = params[:w]; @month_view = true else @m = params[:m] end
    @year = params[:y]; @limit = params[:l].to_i
    @games = search_games_by_checked_platforms(params)
    @filtered = false
    params.each_pair { |key, value|
      if key.to_i > 0 and value.to_i > 0
        @filtered = true
        break
      end
    }
    if not @games.empty?
      if not @month_view
        games = make_games_array(@games, @limit)
        @month = games["games"]
      else
        @month = games_array_week(@games);
        @real_month = params[:m]
      end
    end
    respond_to do |format|
      format.js
    end
  end

  def update_day
    sh = params[:sh].to_i
    @games = search_games_by_checked_platforms(params)
    if params[:type] == 'next'
      games = make_games_array(@games, sh + Limit - 1, false, sh, false)
    else
      games = make_games_array(@games, sh - 2, false, sh - Limit - 1, false)
    end
    @day = games['games']
    if params[:type] == 'next'
      @sh = sh + @day.length - 1
    else
      @sh = sh - 1
    end
    time = Time.parse(params[:date])
    @day_text = time.day
    if @day_text.to_s.length == 1
      @day_text = "0" + @day_text.to_s
    end
    respond_to do |format|
      format.js
    end
  end

  def change_year
    @year = params[:year].to_i
    @lshown = params[:to].to_i
    if @lshown > (2012)
      @lshown = 2012
    elsif @lshown < 1975
      @lshown = 1975
    end
    respond_to do |format|
      format.js
    end
  end

  def close_info_window
    @div_id = params[:id]
    respond_to do |format|
      format.js
    end
  end

  # TODO fix action

  def change_boxart
    @game = Game.find(params[:id])
    respond_to do |format|
      format.js
    end
  end
  def update_boxart
    @game = Game.find(params[:id])
    @game = update_attribute('boxart_dir' => params[:boxart_dir])
    respond_to do |format|
      format.js
    end
  end

  private

  def get_stats(games)
    stats = {"Total" => {"Games", games.length}, "Platforms" => {}, "Publishers" => {}, "Developers" => {}, "Genres" => {}, "Ratings" => {}}
    for game in games
      if stats["Platforms"][game.platform.name]
        stats["Platforms"][game.platform.name] += 1
      else
        stats["Platforms"][game.platform.name] = 1
      end
      for dev in game.developers
        if stats["Developers"][dev.name]
          stats["Developers"][dev.name] += 1
        else
          stats["Developers"][dev.name] = 1
        end
      end
      for pub in game.publishers
        if stats["Publishers"][pub.name]
          stats["Publishers"][pub.name] += 1
        else
          stats["Publishers"][pub.name] = 1
        end
      end
      for gen in game.genres
        if stats["Genres"][gen.name]
          stats["Genres"][gen.name] += 1
        else
          stats["Genres"][gen.name] = 1
        end
      end
      if game.rating
        if stats["Ratings"][game.rating.name]
          stats["Ratings"][game.rating.name] += 1
        else
          stats["Ratings"][game.rating.name] = 1
        end
      end
    end
    stats["Total"] = stats["Total"].sort {|a,b| b[1]<=>a[1]}
    stats["Publishers"] = stats["Publishers"].sort {|a,b| b[1]<=>a[1]}
    stats["Developers"] = stats["Developers"].sort {|a,b| b[1]<=>a[1]}
    stats["Platforms"] = stats["Platforms"].sort {|a,b| b[1]<=>a[1]}
    stats["Genres"] = stats["Genres"].sort {|a,b| b[1]<=>a[1]}
    stats["Ratings"] = stats["Ratings"].sort {|a,b| b[1]<=>a[1]}
    stats
  end

  def games_array_week(games)
    week = []; day_games = []
    rel_date = games.first.release_date
    week << rel_date
    for game in games
      if game.release_date == rel_date
        day_games << game
      else
        week << day_games
        day_games = []
        rel_date = game.release_date
        week << rel_date
        day_games << game
      end
    end
    week << day_games
    week
  end

  def games_array_weeks(games, month, year)
    last_week_day = 7.days.since(first_week_sunday(month, year)); weeks = []; enter = true; last = false; past_entry = last_week_day.day
    platforms_month = []; platforms_week = []; iterate = true
    while enter
      weeks << last_week_day
      week_games = [];  platforms = []
      for game in games
        if iterate
          platforms_month << game.platform unless platforms_month.include?(game.platform)
        end
        if game.release_date < last_week_day and game.release_date >= 7.days.ago(last_week_day)
          platforms << game.platform unless platforms.include?(game.platform)
          week_games << game
        end
      end
      final_week_games = []; day_games = []; iterate = false;
      day_rel_date = week_games.first.release_date if not week_games.empty?
      final_week_games = [day_rel_date] if not week_games.empty?
      platforms_week << last_week_day; platforms_week << platforms
      for week_game in week_games
        if week_game.release_date == day_rel_date
          day_games << week_game
        else
          final_week_games << day_games
          day_rel_date = week_game.release_date
          final_week_games << day_rel_date
          day_games = [week_game]
        end
      end
      final_week_games << day_games
      weeks << final_week_games
      last_week_day = 7.days.since(last_week_day)
      enter = false if last
      last = true if past_entry > last_week_day.day
      past_entry = last_week_day.day
    end
    return { 'games' => weeks, 'platforms' => platforms_week, 'platforms_month' => platforms_month }
  end

  # games => array, games to be formatted for the view(can be an array returned by search_games_by_checked_platforms)
  #
  # limit => int, highest number in array to show in one day (starts in 'start' ends in 'limit'), 0 for no limit[default => 0]
  #
  # include_months => bool, true to return array of months, days and games, false for days and games only[default => false]
  #
  # start => int, specify where to begin to show games on a certain day[default => 0]
  #
  # include_days => bool, true to return array of days and games, false for games in a single day[default => true]
  #
  # returns a Hash, 'games' is the array itself, 'platforms' is an array of platforms by month in every game of the array
  # 'platforms_year' is an array of all the platforms in games of a given year (only if include_months == true)
  # and 'no_games' is an array of month numbers of that year where there are no games (only if include_months == true)
  def make_games_array(games, limit = 0, include_months = false, start = 0, include_days = true)
    first = games.first
    if include_months
      months_year = [first.r_m]
      month = first.r_m
      months_with_no_games = ['01', '02', '03', '04', '05', '06', '07', '08', '09', '10', '11', '12']
      months_with_no_games.delete(month)
      platforms_year = []
    end
    if include_days
      gms = [0]
      next_month = false
      day_change = false
      days_month = [first.r_d]
      day = first.r_d
    else
      gms = [games.length]
    end
    g = 0
    games_in_day = []
    platforms_months = [first.r_m]
    platforms = []
    for game in games
      next_month = month < game.r_m ? true : false if include_months
      if (next_month || day < game.r_d)
        g = 0
        days_month << gms
        gms = [0]
        games_in_day = []
        day = game.r_d
        day_change = month < game.r_m ? true : false if include_months
        days_month << game.r_d unless day_change
      end if include_days
      if month < game.r_m
        months_year << days_month
        platforms_months << platforms
        days_month = []
        platforms = []
        month = game.r_m
        months_with_no_games.delete(month)
        days_month << game.r_d
        months_year << game.r_m
        platforms_months << game.r_m
      end if include_months
      if include_days
        gms << game unless games_in_day.include?(game.full_title) #if (gms.length < limit + 1 or limit == 0)
        games_in_day << game.full_title
      else
        gms << game unless games_in_day.include?(game.full_title) #if g >= start and g <= limit
        games_in_day << game.full_title
      end
      platforms << game.platform unless platforms.include?(game.platform)
      platforms_year << game.platform unless platforms_year.include?(game.platform) if include_months
      g += 1
      gms[0] = g if include_days
    end
    days_month << gms if include_days
    months_year << days_month if include_months
    platforms_months << platforms
    if include_months
      games_array = months_year
    elsif include_days
      games_array = days_month
    else
      games_array = gms
    end
    return { 'games' => games_array, 'platforms' => platforms_months, 'platforms_year' => platforms_year, 'no_games' => months_with_no_games }
  end

  # parameters => hash, parameters passed to the action(includes params ids as params values, year as y, month as m, date as date
  # limit as l, limit of month as li + (no of month), games showing as sh, month to ignore as ig)
  #
  # returns an array of games with the specified platform(s) and date(s), this can be passed on to make_games_array
  def search_games_by_checked_platforms(parameters = { :of => "0", :l => "0", :y => Date.today.year })
    unless parameters[:date]
      year = parameters[:y]
      if parameters[:m]
        if parameters[:w]
          starting_month = 7.days.ago(Date.parse("#{year}-#{parameters[:w][2,2]}-#{parameters[:w][4,2]}")).month.to_s
          ending_month = 1.days.ago(Date.parse("#{year}-#{parameters[:w][2,2]}-#{parameters[:w][4,2]}")).month.to_s
          starting_day = 7.days.ago(Date.parse("#{year}-#{starting_month}-#{parameters[:w][4,2]}")).day.to_s
          ending_day = 1.days.ago(Date.parse("#{year}-#{starting_month}-#{parameters[:w][4,2]}")).day.to_s
        else
          starting_month = parameters[:m]
          ending_month = parameters[:m]
          starting_day = "01"
          ending_day = "31"
        end
      else
        starting_month = "01"
        ending_month = "12"
        starting_day = "01"
        ending_day = "31"
      end
    end
    offset = parameters[:of]
    #    limit = parameters[:l]
    limit = "0"
    games = []
    platform_ids = []; publisher_ids = []; developer_ids = []; genre_ids = []; rating_ids = []
    parameters.each_pair { |key, value|
      if key.to_i > 0 and value.to_i > 0
        platform_ids << value
      elsif value[0,1] == 'p'
        publisher_ids << value.delete('p')
      elsif value[0,1] == 'd'
        developer_ids << value.delete('d')
      elsif value[0,1] == 'n'
        genre_ids << value.delete('n')
      elsif value[0,1] == 'r'
        rating_ids << value.delete('r')
      end
    }
    platform_query = ""; publisher_query = ""; developer_query = ""; genre_query = ""; rating_query = ""
    unless platform_ids.empty?
      platform_ids = platform_ids.join(",")
      platform_query = "platform_id in (#{platform_ids})"
    end
    unless publisher_ids.empty?
      publisher_ids = publisher_ids.join(",")
      publisher_query = "publishers.id in (#{publisher_ids})"
    end
    unless developer_ids.empty?
      developer_ids = developer_ids.join(",")
      developer_query = "developers.id in (#{developer_ids})"
    end
    unless genre_ids.empty?
      genre_ids = genre_ids.join(",")
      genre_query = "genres.id in (#{genre_ids})"
    end
    unless rating_ids.empty?
      rating_ids = rating_ids.join(",")
      rating_query = "rating_id in (#{rating_ids})"
    end
    if parameters[:date]
      games = Game.where("release_date = ?", parameters[:date])
    else
      games = Game.where("release_date >= ? and release_date <= ?", "#{year}-#{starting_month}-#{starting_day}", "#{year}-#{ending_month}-#{ending_day}")
    end
    #      if limit == "0"
    if not platform_ids.empty?
      games = games.where("#{platform_query}")
    end
    if not publisher_ids.empty?
      games = games.where("games.id = games_publishers.game_id and games_publishers.publisher_id = publishers.id and #{publisher_query}").includes(:publishers)
    end
    if not developer_ids.empty?
      games = games.where("games.id = developers_games.game_id and developers_games.developer_id = developers.id and #{developer_query}").includes(:developers)
    end
    if not genre_ids.empty?
      games = games.where("games.id = games_genres.game_id and games_genres.genre_id = genres.id and #{genre_query}").includes(:genres)
    end
    if not rating_ids.empty?
      games = games.where("#{rating_query}")
    end
    games = games.order("release_date asc, hits desc, main_title asc")
  return games
end

def move_boxart old_info, game
  styles = %w(thumb mini medium original)
  bucket = 'vg-timeline'
  AWS::S3::Base.establish_connection!(:access_key_id => 'AKIAIMXJ77QKTJ3QN27Q', :secret_access_key => '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')
  for style in styles
    old_file_path = "images/#{old_info[:year]}/#{old_info[:month]}/#{style}/#{old_info[:path]}"
    new_file_path = "images/#{game.r_y}/#{game.r_m}/#{style}/#{game.make_boxart_path}"
    if AWS::S3::S3Object.exists?(old_file_path, bucket) and old_file_path != new_file_path
      AWS::S3::S3Object.copy old_file_path, new_file_path, bucket
      AWS::S3::S3Object.delete old_file_path, bucket
      policy = AWS::S3::S3Object.acl(new_file_path, bucket)
      policy.grants << AWS::S3::ACL::Grant.grant(:public_read)
      AWS::S3::S3Object.acl(new_file_path, bucket, policy)
    end
  end
end
end
