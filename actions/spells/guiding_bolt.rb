require_relative 'spell'

class GuidingBolt < Action
  include Attack
  include Spell
  Level = 1

  def initialize
    @name = 'Guiding Bolt'
    @ranged = true
  end

  def evaluate_advantage
    return 0 if cannot
    @target = valid_targets.max_by { |foe| evaluate_attack(foe) }
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
    return 0 unless target
    return 0 if target.familiar?
    @target = target
    damage_ratio = average_damage / target.current_hp
    return 0 unless damage_ratio < 1
    (damage_ratio + advantage_value) * hit_chance
  end

  def advantage_value
    ally = next_ally
    return 0 unless ally
    attack = ally_attack ally
    return 0 unless attack
    attack.evaluate_advantage
  end

  def next_ally
    allies = character.allies.select(&:standing?).sort_by(&:initiative)
    index = allies.find_index(character)
    return nil unless index
    allies[index - 1]
  end

  def ally_attack ally
    ally.actions.select(&:attack?).max_by do |attack|
      attack.evaluate_advantage
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

  def effects
    return if @hit == false || target.dead
    target.glowing = true
    p "#{target.name} is glowing."
  end
end
