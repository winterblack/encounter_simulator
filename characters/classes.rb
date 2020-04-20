require 'require_all'
require_relative 'character'
require_relative 'player_character'
require_relative 'spellcaster'
require_all 'actions/class_features'

class Cleric < Character
  include PlayerCharacter
  include Spellcaster
  HD_Type = 8
  SpellAbility = :wis

  def initialize options
    super(options)
    @melee = options[:melee] || true
    @save_proficiencies = [:wis, :cha]
  end

end

class Fighter < Character
  attr_accessor :second_wind_used
  include PlayerCharacter
  HD_Type = 10

  def initialize options
    super(options)
    @melee = options[:melee] || true
    @save_proficiencies = [:str, :con]

    second_wind = SecondWind.new
    second_wind.character = self
    @bonus_actions = [second_wind]
  end
end

class Rogue < Character
  include PlayerCharacter
  HD_Type = 8

  def initialize options
    super(options)
    @melee = options[:melee] || false
    @save_proficiencies = [:dex, :int]
    set_sneak_attack
  end

  private

  def set_sneak_attack
    sneak_attack = Dice "#{(level+1)/2}d6"
    sneaking_attacks = actions.select(&:weapon).select(&:ranged)
    sneaking_attacks.each do |attack|
      attack.sneak_attack = sneak_attack
    end
  end
end

class Wizard < Character
  include PlayerCharacter
  include Spellcaster
  HD_Type = 6
  SpellAbility = :int

  def initialize options
    super(options)
    @melee = options[:melee] || false
    @save_proficiencies = [:int, :wis]
  end

end
