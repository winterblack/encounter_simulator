require_relative 'spell'
require_relative '../../dice'

class HealingWord < Spell
  Level = 1

  def evaluate
    return -1 unless super
    target = choose_target
    healing = [average_healing, target.hp - target.current_hp].min
    healing_value = healing / target.hp.to_f
    target_value = target.actions.map(&:evaluate).max
    target.standing ? healing_value : (healing_value + target_value)
  end

  def perform
    return unless super
    target = choose_target
    target.heal roll_healing
  end

  private

  def roll_healing
    healing_dice.roll + character.spell_ability_score
  end

  def healing_dice
    Dice '1d4'
  end

  def average_healing
    healing_dice.average + character.spell_ability_score
  end

  def choose_target
    if downed_allies.none?
      living_allies.sort_by(&:hp).reverse.min { |a, b| a.current_hp <=> b.current_hp }
    else
      downed_allies.max { |a, b| a.choose_action.evaluate <=> b.choose_action.evaluate }
    end
  end

  def living_allies
    character.allies.reject(&:dead)
  end

  def downed_allies
    living_allies.reject(&:standing)
  end
end
