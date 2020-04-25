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
    return 0 if cannot
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
    value = average_healing / target.hp.to_f
    target.standing? ? value : value + action_value
  end

  def average_healing
    average = healing_dice.average + character.spell_ability_score
    max = target.hp - target.current_hp
    Math.sqrt(average * max)
  end

  def action_value
    target.actions.map(&:evaluate_for_healing).max
  end
end
