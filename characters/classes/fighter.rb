require_relative '../character'
require_relative '../player_character'
require_relative 'second_wind'

class Fighter < Character
  attr_accessor :second_wind_used, :ac
  attr_reader :fighting_styles
  include PlayerCharacter
  HD_Type = 10

  def initialize options
    super(options)
    @melee = options[:melee] || true
    @save_proficiencies = [:str, :con]

    second_wind = SecondWind.new
    second_wind.character = self
    @bonus_actions = [second_wind]
    @fighting_styles = options[:fighting_styles] || []
    train_fighting_styles
  end

  def short_rest
    super
    self.second_wind_used = false
  end

  def train_fighting_styles
    case
    when fighting_styles.include?(:defense)
      self.ac += 1
    when fighting_styles.include?(:great_weapon_fighting)
      set_great_weapon_fighting
    end
  end

  def set_great_weapon_fighting
    actions.select(&:weapon).select(&:great).each do |weapon|
      weapon.gwf = true
    end
  end

  def inspect
    "<#{name} hp=#{current_hp}#{" death_saves=#{death_saves}" if !standing}#{' second_wind_used' if second_wind_used}#{' dead' if dead}#{' dying' if dying}#{' stable' if stable}>"
  end
end
