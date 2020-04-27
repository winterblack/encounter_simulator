require_relative 'spell'

module HealingSpell
  attr_reader :healing

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
    max_healing / target.hp.to_f
  end

  private

  def roll_healing
    @healing = healing_dice.roll + character.spell_ability_score
    p "#{character.name} heals #{target.name} for #{healing}."
    healing
  end

  def valid_targets
    character.allies.reject(&:dead)
  end

  def evaluate_target target
    super
    @value = max_healing / target.hp.to_f
    return short_rest_value if target.pc? && target.foes.none?(&:standing?)
    target.standing? ? value : value + action_value
  end

  def short_rest_value
    if target.standing?
      @value -= target.hit_dice_average
    else
      @value += action_value
    end
  end

  def max_healing
    [average_healing, target.hp - target.current_hp].min
  end

  def average_healing
    healing_dice.average + character.spell_ability_score
  end

  def action_value
    target.actions.map(&:evaluate_for_healing).max
  end
end
