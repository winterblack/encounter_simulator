require_relative 'dice'

class Attack
  attr_reader :name, :attack_bonus, :damage_dice, :ranged

  def initialize name, attack_bonus, damage, options={ ranged:false }
    @name = name
    @attack_bonus = attack_bonus
    @damage_dice = Dice damage
    @ranged = options[:ranged]
  end

  def perform character, target
    hit, crit = roll_to_hit target
    if hit
      damage = damage_dice.roll crit
      p "#{character.name + ' crits! ' if crit}#{target.name} takes #{damage} damage from #{character.name}."
      target.take damage
    else
      p "#{character.name} misses #{target.name}."
    end
  end

  def efficacy target
    hit_chance = (21 + @attack_bonus - target.ac) / 20.0
    hit_chance = hit_chance**2
    damage_dice.average * hit_chance / target.hp
  end

  private

  def roll_to_hit target
    roll = D20.roll
    to_hit = roll + attack_bonus
    hit = roll != 1 && to_hit >= target.ac
    crit = roll == 20
    [hit, crit]
  end
end
