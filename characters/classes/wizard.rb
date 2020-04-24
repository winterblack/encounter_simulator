require_relative '../player_character'
require_relative '../spellcaster'

class Wizard < PlayerCharacter
  include Spellcaster
  HD_Type = 6
  SpellAbility = :int
  attr_accessor :arcane_recovery_used

  def initialize options
    super(options)
    @melee = options[:melee] || false
    @ranged = !melee
    @save_proficiencies = [:int, :wis]
  end

  def short_rest
    super
    use_arcane_recovery unless arcane_recovery_used
  end

  private

  def use_arcane_recovery
    spell_level = (level + 1) / 2
    if spell_slots[spell_level] < spell_slots[spell_level]
      self.spell_slots[spell_level] += 1
      self.arcane_recovery_used = true
    end
  end

  def memorize_spells
    spells.each do |spell|
      case spell
      when :burning_hands then self.actions << BurningHands.new
      end
    end
    super
  end
end
