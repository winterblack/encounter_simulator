require_relative '../actions/spells/healing_spell'
require_relative '../actions/action'

class Healer < Action
  include HealingSpell
  attr_accessor :used_healers_kit_on

  def initialize
    @used_healers_kit_on = []
  end

  def perform
    p "#{character.name} uses a healer's kit."
    super
    self.used_healers_kit_on << target
    target.spell_effects << self
  end

  def after_encounter
    used_healers_kit_on.each { |ally| ally.spell_effects.delete self }
    self.used_healers_kit_on = []
  end

  private

  def healing_dice
    Dice '1d6'
  end

  def evaluate_target target
    super
  end

  def healing
    return 1 if used_healers_kit_on.include?(target) && !target.standing?
    super + 4
  end

  def average_healing
    return 1 if used_healers_kit_on.include?(target) && !target.standing?
    super + 4
  end
end
