require_relative '../action'
require_relative '../save'
require_relative '../attack'
require_relative '../../dice'

module Spell
  def perform
    character.spell_cast_this_turn = true
    character.spell_slots[spell_level] -= 1

    p "#{character.name} casts #{self.class}."
    super
  end

  def evaluate
    return zero if character.spell_cast_this_turn
    super
    worth_spell_slot
  end

  def spell?
    true
  end

  private

  def worth_spell_slot
    @value = 0 if value < 0.5
    @value
  end

  def bonus_action_value
    return zero if character.bonus_actions.include? self
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
