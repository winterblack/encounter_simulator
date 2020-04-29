require_relative 'action'

class Help < Action
  def perform
    choose_target.helper = character
    p "#{character.name} helps #{target.name}."
  end

  private

  def cannot
    !character.standing? || all_ranged? && !character.forward
  end

  def valid_targets
    allies = character.allies.select(&:standing?)
    if all_ranged?
      allies = allies.reject { |ally| ally.melee && !ally.forward }
    end
    allies.sort_by(&:initiative)
  end

  def all_ranged?
    character.foes.select(&:standing?).none?(&:melee)
  end

  def choose_target
    index = valid_targets.find_index(character)
    valid_targets[index - 1]
  end

  def evaluate_target ally
    return zero unless ally
    attack = ally_attack ally
    return zero unless attack
    attack.evaluate_advantage
  end

  def ally_attack ally
    ally.actions.select(&:attack?).max_by do |ally|
      ally.evaluate_advantage
    end
  end
end
