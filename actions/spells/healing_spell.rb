require_relative 'spell'

module HealingSpell
  def perform
    super
    healing = roll_healing
    choose_target.heal healing
  end

  def healing?
    true
  end

  def evaluate_for_healing
    return zero if cannot
    average_healing / character.hp.to_f
  end

  private

  def roll_healing
    healing = healing_dice.roll + character.spell_ability_score
    p "#{character.name} heals #{target.name}."
    healing
  end

  def valid_targets
    character.allies.reject(&:dead)
  end

  def evaluate_target target
    super
    healing = [average_healing, max_healing].min
    healing = average_healing if character.foes.none?(&:standing?)
    value = healing / target.hp.to_f
    target.standing? ? value : value + action_value
  end

  def average_healing
    healing_dice.average + character.spell_ability_score
  end

  def max_healing
    target.hp - target.current_hp
  end

  def action_value
    target.actions.map(&:evaluate_for_healing).max
  end
end
