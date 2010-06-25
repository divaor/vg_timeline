module GamesHelper

  def box_logo(game, size = :thumb, options = { :prototip => false, :tooltip => false, :hover => false })
    h = options[:hover] ? "hover" : ""
    return image_tag(game.boxart.url(size), :alt => game.main_title, :name => game.full_title_colon_limit+"("+game.platform.short_name.upcase+")", :class => "boxart #{size.to_s} #{h}", :onclick => "Tips.hideAll()") unless (options[:prototip] or options[:tooltip])
    return image_tag(game.boxart.url(size), :id => 'tooltip'+game.id.to_s, :alt => game.main_title, :class => "boxart #{size.to_s} #{h}") if (options[:prototip] and not options[:tooltip])
    return image_tag(game.boxart.url(size), :alt => game.main_title, :name => game.full_title_colon_limit+"("+game.platform.short_name.upcase+")", :class => "boxart #{size.to_s} #{h}", :onmouseover => "Ntip(this.name);", :onmouseout => "UnTip()", :onclick => "UnTip()") if (not options[:prototip] and options[:tooltip])
    return image_tag(game.boxart.url(size), :alt => game.main_title, :name => game.full_title_colon_limit+"("+game.platform.short_name.upcase+")", :class => "boxart #{size.to_s} #{h}", :onmouseover => "fullTooltipGameInfo(event, this, #{game.id});Ntip(this.name);", :onmouseout => "UnTip()", :onclick => "UnTip()") if (options[:prototip] and options[:tooltip])
  end

  def rating_logo(rating)
    image_tag("ratings/" + rating.logo_filename, :alt => rating.name, :class => "rating_logo")
  end

  def also_on(game)
    unless game.different_platforms.empty?
      platform_names = ''; add_link = ''
      
      # List of platforms where the game is available
      for diff_platform in game.different_platforms
        platform_names += link_to(diff_platform.platform.short_name.upcase, game_path(diff_platform), :onmouseover => "new Tip(this, '#{diff_platform.platform.name}', { width: 'auto' });") + (diff_platform == game.different_platforms.last ? "" : ", ")
      end

      # "Also on: #{platforms}" table cell
      platforms = content_tag(:td, "Also on:", :class => 'subtitle') + content_tag(:td, raw(platform_names))

      # Link to add to another platform if user is signed in
      if user_signed_in?
        link = pop_up "Add to another platform", new_game_path(:id_diff => game.id)
        add_link = content_tag(:td, raw(link), :colspan => '2')
      end

      # Table
      rows = content_tag(:tr, raw(platforms)) + content_tag(:tr, raw(add_link))
      table = content_tag(:table, raw(rows))

      # Output
      raw content_tag(:div, raw(table), { :class => "shadow round", :id => 'diff_platforms' })
    else
      # Output if game is not available for other platforms
      raw "#{pop_up "+", new_game_path(:id_diff => game.id), :tip => "Add another platform(s)"}" if user_signed_in?
    end
  end

  def info_completion(game)
    bar = content_tag(:span, "Game Info Progress", :id => "completion_label")
    width = "width: #{game.completion}%;"
    bar += content_tag(:div, content_tag(:div, "", { :id => "completion_filled", :style => width }), :id => "completion_bar")
    bar += content_tag(:span, "#{game.completion}%", :id => "completion_text")
    raw bar
  end

  def description(game)
    if game.description
      description = game.description + " "
      description += pop_up "Edit Description", '/edit?id=' + game.id.to_s + '&view=new_description&element_id=game_description&eval=description' if user_signed_in?
    else
      description = "No description has been added for this game. "
      description += pop_up "+", '/edit?id=' + game.id.to_s + '&view=new_description&element_id=game_description&eval=description', :tip => "Add description" if user_signed_in?
    end
    raw description
  end

  def series(game)
    srs = game.series; preq_int = ''; seq_int = ''
    unless srs.nil?
      series = content_tag(:h4, "#{srs.name} series")
      series += (pop_up "Edit Series", '/edit?id=' + game.id.to_s + '&view=add_series&element_id=game_series&eval=series') + " " if user_signed_in?
      series += pop_up "Add new game to series", new_game_path(:series => game.series.id) if user_signed_in?
      if game.prequel
        preq_int += content_tag(:span, "Prev")
        preq_int += tag(:br)
        preq_int += link_to(box_logo(game.prequel, :thumb, :tooltip => true), game_path(game.prequel))
      end
      preq_seq = content_tag(:div, raw(preq_int), :id => "prequel")
      if game.sequel
        seq_int += content_tag(:span, "Next")
        seq_int += tag(:br)
        seq_int += link_to(box_logo(game.sequel, :thumb, :tooltip => true), game_path(game.sequel))
      end
      preq_seq += content_tag(:div, raw(seq_int), :id => "sequel")
      series += content_tag(:div, raw(preq_seq), :id => "prequel_sequel_cont")
      series += content_tag(:div, (pop_up "Add sequel", "/edit?id=#{game.id.to_s}&view=add_sequel&element_id=game_series&eval=series")) if user_signed_in?
      list = content_tag(:h5, "Full List:")
      list += games_list(game.series_list_by_full_title, :gm => game)
      series += content_tag(:div, raw(list), :id => "series_list")
    else
      series = content_tag(:h4, "Series")
      series += pop_up "Add Series", '/edit?id=' + game.id.to_s + '&view=add_series&element_id=game_series&eval=series' if user_signed_in?
    end
    raw series
  end

  def scores(game)
    out = content_tag(:h4, "Scores")
    scores = game.scores
    scores_content = ''
    unless scores.empty?
      total = 0
      count = 0
        for score in scores
          if score.score.to_i < 4
            color = 'bg_color_darkgray'
          elsif score.score.to_i > 7
            color = 'bg_color_lightgray'
          else
            color = 'bg_color_gray'
          end
          scores_content += content_tag(:div, (link_to score.press.name, score.press.url, :target => '_blank'), :class => "scores_press round_left #{color}")
          scores_content += content_tag(:div, (link_to score.score, score.url, :target => '_blank'), :class => "scores round_right #{color}")
          count += 1
          total += score.score.to_i
        end
        out += content_tag(:div, raw(scores_content), :id => "scores_content")
      if total/count < 4
        bg_color = 'bg_color_red'
      elsif total/count > 7
        bg_color = 'bg_color_green'
      else
        bg_color = 'bg_color_yellow'
      end
      avg_score = content_tag(:div, (total / count), :class => "centering")
      avg_score_container = content_tag(:div, raw(avg_score), { :id => "avg_score", :class => bg_color })
      out += content_tag(:div, raw(avg_score_container), :id => "avg_score_container")
    end
    out += content_tag(:div, (pop_up_controller "+", 'new', 'scores', :game_id => game.id, :tip => "Add score(s)"), :class => "scores_add") if user_signed_in?
    raw out
  end

  def awards(game)
    awards_content = ""
    out = content_tag(:h4, "Awards")
    awards = game.awards
    unless awards.empty?
      for award in awards
        awards_content += content_tag(:div, (link_to award.press.name, award.press.url), :class => "award_press_name")
        awards_content += content_tag(:div, award.description, :class => "award_description")
      end
    end
    awards_content += content_tag(:div, (pop_up_controller "+", 'new', 'awards', :game_id => game.id, :tip => "Add award(s)"), :class => "scores_add") if user_signed_in?
    out += content_tag(:div, raw(awards_content), :id => "awards_content")
    raw out
  end

  def rating(game)
    out = ''
    if game.rating
      out = rating_logo(game.rating)
    end
    raw out
  end

  def types(game)
    types = ''
    out = content_tag(:div, "Type:", :class => "right_label")
    unless game.types.empty?
      for type in game.types
        types += type.name
        types += ", " unless type == game.types.last
      end
    end
    types += (pop_up "+", '/edit?id=' + game.id.to_s + '&view=add_type&element_id=types&eval=types', :tip => "Add type(s)") if user_signed_in?
    types += tag(:br)
    out += content_tag(:div, raw(types), :class => "right_description")
    raw out
  end

  def genres(game)
    genres = ''
    out = content_tag(:div, "Genre(s)", :class => "right_label")
    unless game.genres.empty?
      for genre in game.genres
        genres += genre.name
        genres += ", " unless genre == game.genres.last
      end
    end
    genres += (pop_up "+", '/edit?id=' + game.id.to_s + '&view=add_genre&element_id=genres&eval=genres', :tip => "Add genre(s)") if user_signed_in?
    genres += tag(:br)
    out += content_tag(:div, raw(genres), :class => "right_description")
    raw out
  end

  def players(game)
    local_players = ''; online_players = ''
    local = content_tag(:div, "Local:", :class => "right_label")
    if game.local_players
      local_players += "#{game.local_players} Player(s)"
      local_players += ", " if game.local_multi_modes.coop or game.local_multi_modes.vs
      if game.local_multi_modes.coop
        local_players += "Co-op "
        local_players += ", " if game.local_multi_modes.vs
      end
      if game.local_multi_modes.vs
        local_players += "Vs"
      end
    end
    local_players += (pop_up "+", '/edit?id=' + game.id.to_s + '&view=add_players&element_id=players&eval=players', :tip => "Add local player(s)") if user_signed_in?
    local_players += tag(:br)
    local += content_tag(:div, raw(local_players), :class => "right_description")
    out = content_tag(:div, raw(local), :id => "local")
    online = content_tag(:div, "Online:", :class => "right_label")
    if game.online_players
      if game.online_players > 0
        online_players += "#{game.online_players} Players"
        online_players += ", " if game.online_multi_modes.coop or game.online_multi_modes.vs
      else
        online_players += "Not available"
      end
      if game.online_multi_modes.coop
        online_players += "Co-op"
        online_players += ", " if game.online_multi_modes.vs
      end
      if game.online_multi_modes.vs
        online_players += "Vs"
      end
    end
    online_players += (pop_up "+", '/edit?id=' + game.id.to_s + '&view=add_players&element_id=players&eval=players', :tip => "Add online player(s)") if user_signed_in?
    online_players += tag(:br)
    online += content_tag(:div, raw(online_players), :class => "right_description")
    out += content_tag(:div, raw(online), :id => "online")
    raw out
  end

  def key_people(game)
    key_people = ''
    out = content_tag(:div, "Key People:", :class => "right_label")
    unless game.project_leaders.empty?
      for person in game.project_leaders
        key_people += person.industry_person_name + ": "
        key_people += person.position
        key_people += ", " unless person == game.project_leaders.last
      end
    end
    key_people += (pop_up_controller "+", 'new', 'project_leaders', :game_id => game.id, :tip => "Add industry person") if user_signed_in?
    out += content_tag(:div, raw(key_people), :class => "right_description")
    raw out
  end

  def features(game)
    features = ''
    out = content_tag(:div, "Features:", :class => "right_label")
    unless game.features.empty?
      for feature in game.features
        features += feature.description
      end
    end
    features += (pop_up "+", '/edit?id=' + game.id.to_s + '&view=add_features&element_id=features&eval=features', :tip => "Add feature(s)") if user_signed_in?
    features += tag(:br)
    out += content_tag(:div, raw(features), :class => "right_description")
    raw out
  end

  def specs(game)
    specs = ''
    out = content_tag(:div, "Specs:", :class => "right_label")
    unless game.specifications.empty?
      for specification in game.specifications
        specs += specification.description
      end
    end
    specs += (pop_up "+", '/edit?id=' + game.id.to_s + '&view=add_specs&element_id=specifications&eval=specs', :tip => "Add spec(s)") if user_signed_in?
    specs += tag(:br)
    out += content_tag(:div, raw(specs), :class => "right_description")
    raw out
  end

  def peripherals(game)
    peripherals = ''
    out = content_tag(:div, "Peripherals:", :class => "right_label")
    unless game.peripherals.empty?
      for peripheral in game.peripherals
        peripherals += peripheral.name
        peripherals += ", " unless peripheral == game.peripherals.last
      end
    end
    peripherals += (pop_up "+", '/edit?id=' + game.id.to_s + '&view=add_peripherals&element_id=peripherals&eval=peripherals', :tip => "Add peripheral(s)") if user_signed_in?
    peripherals += tag(:br)
    out += content_tag(:div, raw(peripherals), :class => "right_description")
    raw out
  end
end
