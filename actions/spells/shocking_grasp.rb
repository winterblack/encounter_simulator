require_relative 'spell'
require_relative '../../dice'

class ShockingGrasp < Spell
  include AttackBonus
  Level = :cantrip

  def spell_attack
    true
  end

  def evaluate
    target = choose_target
    evaluate_target target
  end

  def perform
    target = choose_target
    advantage = advantage_against target
    hit, crit = roll_to_hit target, advantage
    if hit
      character.disengage
      damage = damage_dice.roll(crit)
      p "#{character.name} shocks #{target.name} for #{damage} damage!"
      target.take damage
    else
      p "#{character.name} misses #{target.name}."
    end
  end

  private

  def damage_dice
    Dice "#{cantrip_dice}d8"
  end

  def choose_target
    targets = character.foes.select(&:standing).select(&:melee)
    targets.max { |a, b| evaluate_target(a) <=> evaluate_target(b) }
  end

  def evaluate_target target
    hit_chance = (21 + attack_bonus - target.ac) / 20.0
    if advantage_against(target) == :advantage
      hit_chance = 1 - (1 - hit_chance)**2
    end
    damage = damage_dice.average
    damage * hit_chance / target.hp
  end

  def advantage_against target
    return :advantage if target.metal_armor
  end
end
