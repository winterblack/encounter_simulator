require_relative 'spell'

class Shield < Action
  include Spell
  Level = 1
  attr_accessor :active

  def initialize character
    @character = character
  end

  def evaluate attack
    return zero if active || cannot
    @value = attack.evaluate_for_shield
    @value = value < 1 ? 0 : value
  end

  def perform
    super
    self.active = true
    character.reaction_used = true
    character.ac += 5
  end
end
