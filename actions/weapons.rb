require_relative 'action'
require_relative 'attack_bonus'
require_relative 'damage_bonus'
require_relative '../dice'

class Weapon < Action
  include AttackBonus
  include DamageBonus
  attr_reader :ability, :attack_bonus, :damage_dice, :ranged

  def evaluate
    value, target = choose_target
    value
  end

  def perform
    value, target = choose_target
    hit, crit = roll_to_hit target
    if hit
      damage = damage_dice.roll(crit) + damage_bonus
      p "#{character.name} crits!" if crit
      p "#{character.name} deals #{damage} damage to #{target.name} with #{self.class}."
      target.take damage
    else
      p "#{character.name} misses #{target.name}."
    end
  end

  private

  def choose_target
    max_value = 0
    best_target = nil
    targets = character.foes.select(&:standing)
    targets = targets.select(&:melee) if targets.any?(&:melee) && !ranged
    targets.each do |target|
      hit_chance = (21 + attack_bonus - target.ac) / 20.0
      damage = damage_dice.average + damage_bonus
      value = damage * hit_chance / target.hp
      if value > max_value
        max_value = value
        best_target = target
      end
    end
    [max_value, best_target]
  end
end

class Greatsword < Weapon
  def initialize
    @ability = :str
    @damage_dice = Dice '2d6'
  end
end

class LightCrossbow < Weapon
  def initialize
    @ability = :dex
    @damage_dice = Dice '1d8'
    @ranged = true
  end
end

class Mace < Weapon
  def initialize
    @name = 'Mace'
    @ability = :str
    @damage_dice = Dice '1d6'
  end
end

class Greataxe < Weapon
  def initialize
    @ability = :str
    @damage_dice = Dice '1d12'
  end
end
