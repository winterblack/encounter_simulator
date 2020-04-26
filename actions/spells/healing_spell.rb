require_relative 'spell'

module HealingSpell
  def perform
    super
    healing = roll_healing
    target.heal healing
  end

  def healing?
    true
  end

  def evaluate_for_healing
    return 0 if cannot
    @target = character
    average_healing_value / target.hp.to_f
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
    value = average_healing_value / target.hp.to_f
    target.standing? ? value : value + action_value
  end

  def average_healing_value
    max_healing = [average_healing, target.hp - target.current_hp].min
    Math.sqrt(average_healing * max_healing)
  end

  def average_healing
    @average ||= healing_dice.average + character.spell_ability_score
  end

  def action_value
    target.actions.map(&:evaluate_for_healing).max
  end
end
