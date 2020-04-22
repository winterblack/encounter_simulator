require_relative '../action'
require_relative '../attack_bonus'
require_relative '../save_dc'

class Spell < Action
  def spell?
    true
  end

  def out_of_combat?
    false
  end

  def evaluate
    return false if cannot
    true
  end

  def perform
    return false if cannot
    character.spell_slots_remaining[spell_level] -= 1
    p "#{character.name} casts #{self.class}!"
    p "#{character.name} has #{character.spell_slots_remaining[1..-1]} spell slots remaining."
    true
  end

  private

  def spell_level
    self.class::Level
  end

  def cannot
    insufficeint_spell_slots || character.spell_cast_this_turn
  end

  def insufficeint_spell_slots
    character.spell_slots_remaining[spell_level] == 0
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
