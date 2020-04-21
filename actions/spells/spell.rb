require_relative '../action'
require_relative '../attack_bonus'
require_relative '../save_dc'

class Spell < Action
  def evaluate
    return false if insufficeint_spell_slots
    true
  end

  def perform
    return false if insufficeint_spell_slots
    character.spell_slots_remaining[spell_level] -= 1 unless spell_level == :cantrip
    p "#{character.name} casts #{self.class}!"
    p "#{character.name} has #{character.spell_slots_remaining[1..-1]} spell slots remaining."
    true
  end

  private

  def spell_level
    self.class::Level
  end

  def insufficeint_spell_slots
    character.spell_slots_remaining[spell_level] == 0 unless spell_level == :cantrip
  end

  def cantrip_dice
    case character.level
    when 1..4
      1
    when 5..10
      2
    when 11..16
      3
    when 17..20
      4
    end
  end
end
