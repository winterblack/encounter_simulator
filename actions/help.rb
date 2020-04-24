require_relative 'action'

class Help < Action
  def perform
    choose_target.helper = character
    p "#{character.name} helps #{target.name}."
  end

  private

  def valid_targets
    character.allies.select(&:standing?).reject { |ally| ally == character }
  end

  def evaluate_target ally
    return 0 unless ally
    attack = ally.actions.select(&:attack?).max { |a, b|
      a.evaluate_help <=> b.evaluate_help
    }
    return 0 unless attack
    attack.evaluate_help
  end
end
