module ApplicationHelper

  def title
    base_title = "VG Timeline"
    return "#{@title} | #{base_title}" if @title
    return base_title
  end

  def meta_description
    if @game and not @game.new_record?
      unless @game.description.nil?
        @game.description
      else
        @game.full_title_colon
      end
    else
      return @meta_description if @meta_description
      return 'VG Timeline'
    end
  end

  def fb_meta_title
    base_title = "VG Timeline"
    return @fb_title if @fb_title
    return base_title
  end

  def pop_up(text, path, options = { :level => 1 })
    options[:level] = 1 if options[:level].to_i < 1 or options[:level].to_i > 4
    #    path = "#{path}&lv=#{options[:level]}"
    if path.slice(0,1) == "/"
      path =  path.slice(1, path.length)
    end
    path = path.slice(path.rindex("/") + 1, path.length) if path.rindex("/")
    link_to text, { :action => path.index("?") ? path.slice(0, path.index("?")) : path, :lv => path.index("?") ? "#{options[:level]}&#{path.slice(path.index("?") + 1, path.length)}" : options[:level] }, :remote => true, :id => "#{options[:level]}level", :class => options[:class] || '', :onmouseover => options[:tip] ? "new Tip(this, '#{options[:tip]}', { style: 'pop+' });" : ""
  end

  def pop_up_controller(text, path, controller, options = {})
    options[:level] = options[:level] ? options[:level] : 1
    link_to text, { :action => path, :controller => controller, :id => options[:id], :lv => options[:level], :game => options[:game_id] }, :remote => true, :id => "#{options[:level]}level", :onmouseover => options[:tip] ? "new Tip(this, '#{options[:tip]}', { style: 'pop+' });" : ""
  end

  def close_button
    link_to(image_tag("window-close.png", :class => "window_close"), { :controller => 'games', :action => 'close_pop', :level => @level }, :remote => true)
  end

  def cur_date_year(year)
    Date.parse(year.to_s+"-#{Date.today.month.to_s}"+"-#{Date.today.day.to_s}") # TODO fix wrong dates
  end

  def cur_date_year_month(year, month)
    if Date.valid_civil?(year, month, Date.today.day)
      Date.parse(year.to_s+"-"+month.to_s+"-#{Date.today.day.to_s}")
    else
      i = Date.today.day - 1
      while not Date.valid_civil?(year, month, i)
        i -= 1
      end
      Date.parse(year.to_s+"-"+month.to_s+"-"+i.to_s)
    end
  end

  def cur_date_month(month)
    Date.parse("#{Date.today.year.to_s}"+"-"+month.to_s+"-#{Date.today.day.to_s}") # TODO fix wrong dates
  end

  def cur_date_day(day)
    Date.parse("#{Date.today.year.to_s}"+"-#{Date.today.month.to_s}"+"-"+day.to_s)
  end

  def cur_date_all(year, month, day)
    Date.parse(year.to_s+"-"+month.to_s+"-"+day.to_s)
  end

  def cur_year
    Date.today.year
  end

  def cur_month
    Date.today.month
  end

  def cur_day
    Date.today.day
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

  def last_year
    3.years.since(Date.today).year
  end

  def close_button
    image_tag("window-close.png", :class => "window_close")
  end

  def games_list(games, options = {})
    options = { :gm => "", :series => false }.merge(options)
    list = ""
    series = ""
    if options[:series]
      games.sort! do |a, b|
        (a.series_id.to_i <=> b.series_id.to_i).nonzero? ||
        (b.release_date <=> a.release_date)
      end
    end
    for game in games
      list_output = ""
      link = ""
      series_name = game.series ? game.series.name : "<No Series>"
      list += content_tag(:span, series_name, :class => 'list_series_name') if options[:series] and series != game.series
      list += game.r_y + ' - '
      list += content_tag(:span, game.full_title_colon_limit, :class => game == options[:gm] ? "showing" : "")
      diff_p = game.different_platforms
      pre = "(" + link_to_unless(game == options[:gm], game.platform.short_name.upcase, game_path(game))
      unless diff_p.empty?
        diff_p.each do |g|
          link = ""
          pre2 = g == diff_p.first ? pre : ""
          unless options[:series] and not g.characters.include?(@character)
            link = (', ' + link_to_unless(g == options[:gm], g.platform.short_name.upcase, game_path(g)))
          end
          list_output += pre2 + link  + (g == diff_p.last ? ")" : "")
        end
      else
        list_output += " (#{link_to_unless game == options[:gm], game.platform.short_name.upcase, game_path(game)})"
      end
      list_output += " (unreleased)" if game.release_date > Date.today
      list_output += tag(:br)
      list += content_tag(:span, raw(list_output))
      series = game.series
    end
    raw list
  end

  def characters_list(characters_games)
    list = ""
    for characters_game in characters_games
      list += character_pic(characters_game.character)
    end
    raw list
  end

  def character_pic(character, options = {})
    options = { :make_link => true }.merge(options)
    pic = image_tag(character.picture.url(:mini), :alt => character.name, :name => character.name, :onmouseover => "new Tip(this, '#{character.name}', { width: 'auto' })")
    return pic unless options[:make_link]
    return pop_up_controller(pic, 'show', 'characters', :id => character.id)
  end
end
