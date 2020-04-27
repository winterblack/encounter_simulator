require_relative 'spell'

class Shield < Action
  include Spell
  Level = 1
  attr_accessor :active

  def evaluate attack
    return zero if cannot
    value = attack.evaluate_for_shield
    @value = value < 1 ? 0 : value
  end

  def perform
    super
    character.reaction_used = true
    character.ac += 5
    p "#{character.name} has #{character.ac} ac."
    character.spell_effects << self
  end

  def start_turn
    if character.spell_effects.include? self
      character.ac -= 5
      p "Shield ends. #{character.name} has #{character.ac} ac."
      character.spell_effects.delete self
    end
  end
end
