require_relative 'healing_spell'

class HealingWord < Spell
  include HealingSpell
  Level = 1

  private

  def healing_dice
    Dice '1d4'
  end
end
