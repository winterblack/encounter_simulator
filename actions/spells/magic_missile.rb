require_relative 'spell'

class MagicMissile < Action
  include Spell

  Level = 1

  def perform
    super
    @target = choose_target
    damage = Dice('3d4').roll + 3
    p "Three darts of magical force strike #{target.name} for #{damage} damage."
    target.take damage
  end

  private

  def valid_targets
    character.foes.select(&:standing?)
  end

  def evaluate_target target
    super
    value = 10.5 / target.current_hp
    value > 1.05 ? 0 : value
  end
end
