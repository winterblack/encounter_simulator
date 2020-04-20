require_relative 'action'

class Spell < Action
  def evaluate
    spell_level = self.class::Level
    return false if character.spell_slots_remaining[spell_level] < 1
    true
  end

  def perform
    spell_level = self.class::Level
    character.spell_slots_remaining[spell_level] -= 1
  end
end
