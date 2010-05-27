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
        link = pop_up "Add to another platform", new_game_path(:id_diff => @game.id)
        add_link = content_tag(:td, raw(link), :colspan => '2')
      end

      # Table
      rows = content_tag(:tr, raw(platforms)) + content_tag(:tr, raw(add_link))
      table = content_tag(:table, raw(rows))

      # If game has sub title
      sub = game.sub_title.empty? ? "" : "sub"

      # Output
      raw content_tag(:div, raw(table), { :class => "round #{sub}", :id => 'diff_platforms' })
    else
      # Output if game is not available for other platforms
      raw "(#{pop_up "Add to another platform", new_game_path(:id_diff => game.id)})" if user_signed_in?
    end
  end

  def description(game)
    if game.description
      description = game.description + " "
      description += pop_up "Edit Description", '/edit?id=' + @game.id.to_s + '&view=new_description&element_id=game_description&eval=description' if user_signed_in?
    else
      description = "No description has been added for this game. "
      description += pop_up "Add Description", '/edit?id=' + @game.id.to_s + '&view=new_description&element_id=game_description&eval=description' if user_signed_in?
    end
    raw description
  end

  def series(game)
    srs = @game.series; links = ''; preq_int = ''; seq_int = ''
    unless srs.nil?
      series = content_tag(:h4, "#{srs.name} series")
      series += (pop_up "Edit Series", '/edit?id=' + game.id.to_s + '&view=add_series&element_id=game_series&eval=series') + " " if user_signed_in?
      series += pop_up "Add new game to series", new_game_path(:series => game.series.id) if user_signed_in?
      if game.prequel
        preq_int += content_tag(:span, "Prev")
        preq_int += tag(:br)
        preq_int += link_to(box_logo(game.prequel, :thumb, :tooltip => true), game_path(game.prequel))
      end
      preq_int += pop_up "Add sequel", "/edit?id=#{@game.id.to_s}&view=add_sequel&element_id=game_series&eval=series" if user_signed_in?
      preq_seq = content_tag(:div, raw(preq_int), :id => "prequel")
      if game.sequel
        seq_int += content_tag(:span, "Next")
        seq_int += tag(:br)
        seq_int += link_to(box_logo(game.sequel, :thumb, :tooltip => true), game_path(game.sequel))
      end
      preq_seq += content_tag(:div, raw(seq_int), :id => "sequel")
      series += content_tag(:div, raw(preq_seq), :id => "prequel_sequel_cont")
      list = content_tag(:h5, "Full List:")
      list += games_list(game.series_list_by_full_title, :gm => game)
      series += content_tag(:div, raw(list), :id => "series_list")
    else
      series = content_tag(:h4, "Series")
      series += pop_up "Add Series", '/edit?id=' + game.id.to_s + '&view=add_series&element_id=game_series&eval=series' if user_signed_in?
    end
    raw series
  end
end
