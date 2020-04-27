require_relative 'spell'

class ShieldOfFaith < Action
  include Spell
  Level = 1

  def perform
    super
    target.ac += 2
    p "#{target.name} now has #{target.ac} ac."
    target.shield_of_faith = true
    character.concentration = self
  end

  def end_concentration
    target.ac -= 2
    target.shield_of_faith = false
    character.concentration = nil
  end

  private

  def evaluate_target target
    @target = target
    return 0 if character.concentration
    return 0 if target.shield_of_faith
    return 0 unless dangerous_action&.attack?
    damage = dangerous_action.average_damage
    damage * 0.1 / target.current_hp
  end

  def valid_targets
    character.allies.select(&:standing?).reject(&:familiar?)
  end

  def dangerous_action
    character.foes.select(&:standing?).flat_map(&:actions).max do |a, b|
      a.evaluate <=> b.evaluate
    end
  end
end
