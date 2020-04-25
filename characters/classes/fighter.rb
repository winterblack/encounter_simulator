require_relative '../player_character'
require_relative '../class_features/second_wind'
require_relative '../class_features/great_weapon_fighting'

class Fighter < PlayerCharacter
  attr_accessor :second_wind_used, :ac
  attr_reader :fighting_styles

  HD_Type = 10

  def initialize options
    super(options)
    @melee = options[:melee] || true
    @ranged = !melee
    @save_proficiencies = [:str, :con]
    @fighting_styles = options[:fighting_styles]
    train_second_wind
    train_fighting_styles
  end

  def short_rest
    super
    self.second_wind_used = false
  end

  def inspect
    "#<#{self.class} hp=#{current_hp} hit_dice=[#{hit_dice_string}]#{" second_wind_used" if second_wind_used}#{" death_saves=#{death_saves}" unless standing?}#{' dead' if dead}#{' dying' if dying}#{' stable' if stable}>"
  end

  private

  def train_second_wind
    second_wind = SecondWind.new
    second_wind.character = self
    @bonus_actions = [second_wind]
  end

  def train_fighting_styles
    fighting_styles.each do |fighting_style|
      case fighting_style
      when :defense then self.ac += 1
      when :great_weapon_fighting then train_great_weapon_fighting
      end
    end
  end

  def train_great_weapon_fighting
    actions.select(&:weapon?).select(&:great).each do |weapon|
      weapon.damage_dice.extend GreatWeaponFighting
    end
  end
end
