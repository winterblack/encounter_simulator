require_relative 'healing_spell'

class CureWounds < Action
  include Spell
  include HealingSpell
  Level = 1

  private

  def healing_dice
    Dice '1d8'
  end
end
