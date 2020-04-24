require_relative 'action'

class Help < Action
  def perform
    choose_target.helper = character
    p "#{character.name} helps #{target.name}."
  end

  private

  def choose_target
    return nil unless character.standing?
    allies = character.allies.select(&:standing?).sort_by(&:initiative)
    index = allies.find_index(character)
    allies[index - 1]
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
