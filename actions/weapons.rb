require_relative 'action'
require_relative 'attack_bonus'
require_relative 'damage_bonus'
require_relative '../dice'

class Weapon < Action
  include AttackBonus
  include DamageBonus
  attr_reader :ability, :attack_bonus, :damage_dice, :ranged, :finesse
  attr_accessor :sneak_attack

  def weapon
    true
  end

  def evaluate
    target = choose_target
    evaluate_target target
  end

  def perform
    target = choose_target
    binding.pry unless target
    engage target unless ranged
    hit, crit = roll_to_hit target
    if hit
      damage = damage_dice.roll(crit) + damage_bonus
      sneaking = sneaking? target
      damage += sneak_attack.roll(crit) if sneaking
      p "#{"#{character.name} sneak attacks! " if sneaking}#{"#{character.name} crits! " if crit}#{character.name} deals #{damage} damage to #{target.name} with #{self.class}."
      target.take damage
    else
      p "#{character.name} misses #{target.name}."
    end
  end

  private

  def sneaking? target
    sneak_attack && target.engaged.count > 0
  end

  def choose_target
    targets = character.foes.select(&:standing)
    targets = targets.select(&:melee) if targets.any?(&:melee) && !ranged
    targets.max { |a, b| evaluate_target(a) <=> evaluate_target(b) }
  end

  def evaluate_target target
    hit_chance = (21 + attack_bonus - target.ac) / 20.0
    damage = damage_dice.average + damage_bonus
    damage * hit_chance / target.hp
  end

  def engage target
    character.engaged << target unless character.engaged.include? target
    target.engaged << character unless target.engaged.include? character
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
