require_relative 'action'
require_relative 'spell'
require_relative 'attack_bonus'
require_relative 'save_dc'
require_relative '../dice'

class BurningHands < Spell
  include SaveDC
  Level = 1
  Damage = Dice '3d6'

  def evaluate
    return -1 unless super
    targets = choose_targets
    count = targets.count
    average_dex = targets.sum { |target| target.dex } / count
    fail_chance = (save_dc - average_dex -1)/20.0
    average_damage = Damage.average
    average_damage * fail_chance + (average_damage * (fail_chance - 1) / 2)
  end

  def perform
    super
    p "#{character.name} casts Burning Hands!"
    targets = choose_targets
    damage = Damage.roll
    targets.each do |target|
      roll = target.roll_save(character.class::SpellAbility)
      if roll < save_dc
        target.take damage
        p "#{target.name} burns for #{damage} damage."
      else
        target.take(damage/2)
        p "#{target.name} burns for #{damage/2} damage."
      end
    end
    p "#{character.name} has #{character.spell_slots_remaining} spell slots remaining."
  end

  private

  def choose_targets
    character.foes.min(3) { |foe| foe.current_hp }
  end
end
