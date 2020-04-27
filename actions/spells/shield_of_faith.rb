require_relative 'spell'

class ShieldOfFaith < Action
  include Spell
  Level = 1

  def concentration?
    true
  end

  def perform
    super
    target.spell_effects << self
    target.ac += 2
    p "#{target.name} now has #{target.ac} ac."
  end

  def after_encounter
    drop_concentration if character.concentrating_on == self
  end

  def drop_concentration
    super
    target.spell_effects.delete self
    target.ac -= 2
  end

  private

  def evaluate_target target
    @target = target
    return 0 if cannot
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
