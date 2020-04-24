require_relative 'spell'

class GuidingBolt < Spell
  include Attack
  Level = 1

  def initialize
    @name = 'Guiding Bolt'
    @ranged = true
  end

  def evaluate_help
    return 0 if cannot
    @target = valid_targets.max { |a, b| evaluate_attack(a) <=> evaluate_attack(b) }
    return 0 if !target || advantage?
    chance = hit_chance
    advantage = 1 - (1  - chance)**2
    average_damage * (advantage - chance) / target.current_hp.to_f
  end

  private

  def evaluate_attack target
    @target = target
    average_damage * hit_chance / target.current_hp
  end

  def evaluate_target target
    super + advantage_value
  end

  def advantage_value
    ally = next_ally
    return 0 unless ally
    attack = ally_attack ally
    return 0 unless attack
    value = attack.evaluate_help
  end

  def next_ally
    allies = character.allies.select(&:standing?).sort_by(&:initiative)
    index = allies.find_index(character)
    allies[index - 1]
  end

  def ally_attack ally
    ally.actions.select(&:attack?).max do |a, b|
      a.evaluate_help <=> b.evaluate_help
    end
  end

  def damage_dice
    Dice '4d6'
  end

  def average_damage
    damage_dice.average
  end

  def strike
    damage = roll_damage
    strike_message damage
    target.take damage
  end

  def roll_damage
    damage_dice.roll(crit)
  end
end
