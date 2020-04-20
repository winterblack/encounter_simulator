require_relative '../character'
require_relative '../player_character'

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
