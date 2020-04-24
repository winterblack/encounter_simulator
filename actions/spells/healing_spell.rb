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

  private

  def roll_healing
    healing = healing_dice.roll + character.spell_ability_score
    p "#{character.name} heals #{target.name} for #{healing}."
    healing
  end

  def valid_targets
    character.allies.reject(&:dead)
  end

  def evaluate_target target
    super
    healing = [average_healing, max_healing].min
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
    target.actions.map(&:evaluate).max
  end
end
