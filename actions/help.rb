require_relative 'action'

class Help < Action
  def perform
    choose_target.helper = character
    p "#{character.name} helps #{target.name}."
  end

  private

  def valid_targets
    character.allies.select(&:standing?).reject do |ally|
      ally == character
    end
  end

  def evaluate_target ally
    return 0 unless ally
    attack = ally_attack ally
    return 0 unless attack
    attack.evaluate_help
  end

  def ally_attack ally
    ally.actions.select(&:attack?).max do |a, b|
      a.evaluate_help <=> b.evaluate_help
    end
  end
end
