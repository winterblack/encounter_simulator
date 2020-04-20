require_relative 'spell'
require_relative '../../dice'

class BurningHands < Spell
  include SaveDC
  Level = 1

  def evaluate
    return -1 unless super
    targets = choose_targets
    count = targets.count
    average_dex = targets.sum { |target| target.dex } / count
    fail_chance = (save_dc - average_dex -1)/20.0
    average_damage = damage.average
    average_damage * fail_chance + (average_damage * (fail_chance - 1) / 2)
  end

  def perform
    return unless super
    targets = choose_targets
    damage_roll = damage.roll
    targets.each do |target|
      roll = target.roll_save(character.class::SpellAbility)
      if roll < save_dc
        p "#{target.name} burns for #{damage_roll} damage."
        target.take damage_roll
      else
        p "#{target.name} burns for #{damage_roll/2} damage."
        target.take(damage_roll/2)
      end
    end
  end

  private

  def damage
    Dice '3d6'
  end

  def choose_targets
    character.foes.min(3) { |foe| foe.current_hp }
  end
end
