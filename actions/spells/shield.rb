require_relative 'spell'

class Shield < Action
  include Spell
  Level = 1

  def initialize character
    @character = character
  end

  def evaluate attack
    return zero if character.shield_active || cannot
    @value = attack.evaluate_for_shield
  end

  def perform
    super
    character.shield_active = true
    character.reaction_used = true
    character.ac += 5
  end
end
