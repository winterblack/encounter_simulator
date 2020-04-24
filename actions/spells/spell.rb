require_relative '../action'
require_relative '../save'
require_relative '../../dice'

class Spell < Action
  def perform
    character.spell_cast_this_turn = true
    character.spell_slots[spell_level] -= 1

    p "#{character.name} casts #{self.class}."
    p "#{character.name}' spell slots: #{character.spell_slots}"
  end

  def spell?
    true
  end

  private

  def bonus_action_value
    return 0 if bonus_action
    character.bonus_actions.reject(&:spell?).map(&:evaluate).max || 0
  end

  def spell_level
    self.class::Level
  end

  def cannot
    insufficient_spell_slots || character.spell_cast_this_turn
  end

  def insufficient_spell_slots
    character.spell_slots[spell_level] == 0
  end
end
