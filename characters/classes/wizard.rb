require_relative '../character'
require_relative '../player_character'
require_relative '../spellcaster'

class Wizard < Character
  include PlayerCharacter
  include Spellcaster
  HD_Type = 6
  SpellAbility = :int
  attr_accessor :arcane_recovery_used

  def initialize options
    super(options)
    @melee = options[:melee] || false
    @save_proficiencies = [:int, :wis]
  end

  def short_rest
    super
    return if arcane_recovery_used
    spell_level = (level + 1) / 2
    if spell_slots_remaining[spell_level] < spell_slots[spell_level]
      self.spell_slots_remaining[spell_level] += 1
      self.arcane_recovery_used = true

      p "#{name} uses arcane recovery"
      p "#{name} has #{spell_slots_remaining[1..-1]} spell slots remaining."
    end
  end

  def inspect
    "<#{name} hp=#{current_hp}#{" spell_slots=#{spell_slots_remaining[1..-1]}" if spell_slots}#{" arcane_recovery_used" if arcane_recovery_used}#{" death_saves=#{death_saves}" if !standing}#{' dead' if dead}#{' dying' if dying}#{' stable' if stable}>"
  end
end
