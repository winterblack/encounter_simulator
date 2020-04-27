require_relative '../action'
require_relative '../save'
require_relative '../attack'
require_relative '../../dice'

module Spell
  def perform
    character.spell_cast_this_turn = true
    character.spell_slots[spell_level] -= 1
    character.concentrating_on = self if concentration?

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

  def concentration?
    false
  end

  def drop_concentration
    p "#{character.name} drops concentration on #{self.class}."
    character.concentrating_on = nil
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
    return true if insufficient_spell_slots
    return true if character.spell_cast_this_turn
    return true if concentration? && character.concentrating_on
    return true if target_has_spell_effect
  end

  def insufficient_spell_slots
    character.spell_slots[spell_level] == 0
  end

  def target_has_spell_effect
    target && target.spell_effects.map(&:class).include?(self.class)
  end
end
