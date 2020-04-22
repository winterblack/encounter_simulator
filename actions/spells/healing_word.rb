require_relative 'spell'
require_relative '../../dice'

class HealingWord < Spell
  Level = 1

  def out_of_combat?
    true
  end

  def evaluate
    return 0 unless super
    target = choose_target
    healing = [average_healing, target.hp - target.current_hp].min
    return 0 if healing == 0
    healing_value = healing / target.hp.to_f
    value = target.standing ? healing_value : (healing_value + 1)
    value < 1 ? 0 : value
  end

  def perform
    return unless super
    target = choose_target
    target.heal roll_healing
  end

  private

  def roll_healing
    healing_dice.roll + character.spell_ability_score + life_domain_bonus
  end

  def healing_dice
    Dice '1d4'
  end

  def average_healing
    healing_dice.average + character.spell_ability_score + life_domain_bonus
  end

  def life_domain_bonus
    character.domain == :life ? 3 : 0
  end

  def choose_target
    living_allies.sort_by(&:hp).reverse.min { |a, b| a.current_hp <=> b.current_hp }
  end

  def living_allies
    character.allies.reject(&:dead)
  end

  def downed_allies
    living_allies.reject(&:standing)
  end
end
