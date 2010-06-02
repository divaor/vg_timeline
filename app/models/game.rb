class Game < ActiveRecord::Base
  include Paperclip

  attr_accessor :boxart_dir
  belongs_to :platform
  belongs_to :game_type
  belongs_to :series
  belongs_to :market
  belongs_to :rating
  belongs_to :local_multi_modes, :class_name => "MultiplayerMode", :foreign_key => :local_multi_modes_id
  belongs_to :online_multi_modes, :class_name => "MultiplayerMode", :foreign_key => :online_multi_modes_id
  belongs_to :sequel, :class_name => "Game", :foreign_key => :sequel_id
  belongs_to :prequel, :class_name => "Game", :foreign_key => :prequel_id
  belongs_to :re_release, :class_name => "Game", :foreign_key => :re_release_id
  belongs_to :remake, :class_name => "Game", :foreign_key => :remake_id
  has_and_belongs_to_many :achievements
  has_and_belongs_to_many :developers
  has_and_belongs_to_many :publishers
  has_and_belongs_to_many :features
  has_and_belongs_to_many :genres
  has_and_belongs_to_many :peripherals
  has_and_belongs_to_many :specifications
  has_and_belongs_to_many :types
  has_and_belongs_to_many :different_markets, :class_name => "Game", :join_table => :different_markets_games, :foreign_key => :different_market_id
  has_and_belongs_to_many :different_platforms, :class_name => "Game", :join_table => :different_platforms_games, :foreign_key => :different_platform_id
  has_many :scores
  has_many :press, :through => :scores
  has_many :characters_games
  has_many :characters, :through => :characters_games
  has_many :project_leaders
  has_many :industry_people, :through => :project_leaders
  has_many :awards

  validates :main_title, :release_date, :platform_id, :presence => true
  has_attached_file :boxart, :storage => :s3, :s3_credentials => "#{Rails.root}/config/s3.yml", :url => "/images/:release_year/:release_month/:style/:title", :styles => { :medium => "400x400>", :thumb => "120x120>", :mini => "50x50>" }, :path => "/images/:release_year/:release_month/:style/:title"

  def full_title
    main_title + " " + sub_title
  end

  def full_title_limit
    return "#{full_title.slice(0,49)}..." if full_title.length > 50
    full_title
  end

  def full_title_colon
    f_t = main_title
    return f_t if sub_title.empty?
    f_t = "#{f_t}:" if main_title.rindex(':').nil? and sub_title.rindex(':').nil?
    "#{f_t} #{sub_title}"
  end

  def full_title_colon=(name)
    unless name.empty?
      title = name.split(':')
      title[1] = "" unless title[1]
      self.main_title = title[0].strip
      self.sub_title = title[1].strip
    end
  end

  def full_title_colon_limit
    return "#{full_title_colon.slice(0, 49)}..." if full_title_colon.length > 50
    full_title_colon
  end

  def result_display
    full_title_colon_limit
  end

  def result_picture
    boxart.url(:mini)
  end

  def series_list_by_full_title
    games_titles = []
    games = []
    for game in self.series.games
      unless games_titles.include?(game.full_title)
        games_titles << game.full_title
        games << game
      end
    end if self.series
    
    games.sort { |a, b| b.release_date <=> a.release_date}
  end

  def get_characters_type
    characters_type = {}
    playable_characters = characters_games.select { |a| a.playable == true }
    non_playable_characters = characters_games.select { |a| a.playable == false}
    characters_type['playable'] = playable_characters
    characters_type['nonplayable'] = non_playable_characters
    return characters_type
  end

  def added_by
    table = ModTable.where("name = ?", 'games').first
    Modification.where("added = true and mod_table_id = ? and modified_id = ?", table.id, self.id).first
  end

  def modified_by
    table = ModTable.where("name = ?", 'games').rirst
    Modification.where("modified = true and table_id = ? and modified_id = ?", table.id, self.id).all
  end

  def completion
    perc = 0
    values = { 'title' => 10, 'release_date' => 11, 'boxart' => 11,
      'developer' => 8, 'publisher' => 8, 'platform' => 8, 'description' => 7,
      'genre' => 8, 'rating' => 8, 'players' => 6,
      'also_on' => 5, 'market' => 5, 'type' => 5 } # TODO update completion %
    perc = perc + values['title'] unless main_title.nil?
    perc = perc + values['release_date'] unless release_date.nil?
    perc = perc + values['boxart'] unless boxart_file_name.nil?
    perc = perc + values['developer'] unless developers.empty?
    perc = perc + values['publisher'] unless publishers.empty?
    perc = perc + values['platform'] unless platform.nil?
    perc = perc + values['description'] unless description.nil?
    perc = perc + values['genre'] unless genres.empty?
    perc = perc + values['rating'] unless rating.nil?
    perc = perc + values['players'] unless local_players.nil? and online_players.nil?
    perc = perc + values['also_on'] unless different_platforms.empty?
    perc = perc + values['market'] unless market.nil?
    perc = perc + values['type'] unless types.empty?
    return perc
  end

  def different_platforms_same_day
    games = []
    for game in self.different_platforms
      if game.release_date == self.release_date
        games << game
      end
    end
    games
  end

  def r_d
    release_date.strftime('%d')
  end

  def r_m
    release_date.strftime('%m')
  end

  def r_m_t
    release_date.strftime('%B')
  end

  def r_y
    release_date.strftime('%Y')
  end

  def boxart_path
    unless boxart == "empty_boxart"
      "#{r_y}/#{r_m}/#{boxart}"
    else
      boxart
    end
  end

  def year_dir
    File.expand_path("#{Rails.root}/public/images/#{r_y}")
  end

  def month_dir
    File.expand_path("#{Rails.root}/public/images/#{r_y}/#{r_m}")
  end

  def same_file?(prev_file, new_file)
    return true if FileUtils.compare_file(prev_file, new_file)
    return false
  end

  def platform_name
    platform.name if platform
  end

  def platform_name=(name)
    self.platform = Platform.find_or_create_by_name(name) unless name.blank? # TODO cannot create platform if not assigned a short_name
  end

  def series_name
    series.name if series
  end

  def series_name=(name)
    self.series = Series.find_or_create_by_name(name) unless name.blank?
  end

  def type_name
    types.first.name if types.first
  end

  def type_name=(id)
    type = Type.find(id)
    self.types << type unless types.exists?(type)
  end

  def local_multi_modes_types
    coop = local_multi_modes.coop ? "Co-op" : ""
    vs = local_multi_modes.vs ? "Vs" : ""
    also = local_multi_modes.coop and local_multi_modes.vs ? " & " : ""
    coop + also + vs
  end

  def character_name
    ""
  end

  def character_name=(name)
    char = Character.find_or_create_by_name(name.strip) unless name.blank?
    self.characters << char unless characters.include?(char)
  end

  def feature_descriptions
    feats = []
    if features
      for feature in features
        feats << feature.description
      end
    end
    feats.split.join(", ")
  end

  def feature_descriptions=(descriptions)
    feat_desc = descriptions.split(",")
    temp_features = []
    for description in feat_desc
      temp_features << Feature.find_or_create_by_description(description.strip) unless description.blank?
    end
    self.features = temp_features unless temp_features.empty?
  end

  def specification_descriptions
    specs = []
    if specifications
      for specification in specifications
        specs << specification.description
      end
    end
    specs.split.join(", ")
  end

  def specification_descriptions=(descriptions)
    spec_desc = descriptions.split(",")
    temp_specifications = []
    for description in spec_desc
      temp_specifications << Specification.find_or_create_by_description(description.strip) unless description.blank?
    end
    self.specifications = temp_specifications unless temp_specifications.empty?
  end

  def developer_names
    devs = []
    if developers
      for developer in developers
        devs << developer.name
      end
    end
    devs.split.join(", ")
  end

  def developer_names=(names)
    dev_names = names.split(",")
    temp_developers = []
    for name in dev_names
      temp_developers << Developer.find_or_create_by_name(name.strip) unless name.blank?
    end
    self.developers = temp_developers unless temp_developers.empty?
  end

  def publisher_names
    pbs = []
    if publishers
      for publisher in publishers
        pbs << publisher.name
      end
    end
    pbs.split.join(", ")
  end

  def publisher_names=(names)
    pb_names = names.split(",")
    temp_publishers = []
    for name in pb_names
      temp_publishers << Publisher.find_or_create_by_name(name.strip) unless name.blank?
    end
    self.publishers = temp_publishers unless temp_publishers.empty?
  end

  def prequel_name
    prequel.full_title_colon if prequel
  end

  def prequel_name=(name)
    unless name.empty?
      title = name.split(':')
      title[1] = "" unless title[1]
      preq = Game.where("LOWER(main_title) = ? AND LOWER(sub_title) = ?", title[0].downcase.strip, title[1].downcase.strip).first
      if preq
        preq.update_attribute(:sequel, self)
        preq.update_attribute(:series_id, series_id) if series_id
        self.prequel = preq
      end
    end
  end

  def sequel_name
    sequel.full_title_colon if sequel
  end

  def sequel_name=(name)
    unless name.empty?
      title = name.split(':')
      title[1] = "" unless title[1]
      seq = Game.where("LOWER(main_title) = ? AND LOWER(sub_title) = ?", title[0].downcase.strip, title[1].downcase.strip).first
      if seq
        seq.update_attribute(:prequel, self)
        seq.update_attribute(:series_id, series_id) if series_id
        self.sequel = seq
      end
    end
  end

  def make_boxart_path
    name = main_title
    name = "#{main_title} #{sub_title}" if sub_title
    box_name = name.downcase
    box_name = box_name.tr("\'\"", "")
    box_name = box_name.tr('.:;-/\\', " ")
    box_name = box_name.split.join('_')
    box_name = "#{box_name}_#{platform.short_name}"
  end

  private

  def save_file
    if not boxart_dir and not id
      empty_boxart_path
    else
      if !File.exists?(year_dir)
        Dir.mkdir(year_dir)
      end
      if !File.exists?(month_dir)
        Dir.mkdir(month_dir)
      end
      if boxart_dir
        FileUtils.copy(boxart_dir.local_path, file_path)
      end
    end
  end

  def file_path
    filename = make_boxart_path
    File.expand_path("#{RAILS_ROOT}/public/images/#{r_y}/#{r_m}/#{filename}")
  end

  def empty_boxart_path
    self.boxart = "empty_boxart"
  end
end
