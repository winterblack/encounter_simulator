require_relative 'action'
require_relative 'attack_bonus'
require_relative 'damage_bonus'
require_relative '../dice'

class Weapon < Action
  include AttackBonus
  include DamageBonus
  attr_reader :ability, :attack_bonus, :damage_dice, :name, :ranged, :great, :finesse
  attr_accessor :sneak_attack, :gwf

  def initialize name, ability, damage, options={}
    @name = name.to_s.sub('_', ' ')
    @ability = ability
    @damage_dice = Dice damage
    @ranged = options[:ranged]
    @great = options[:great]
    @finesse = options[:finesse]
  end

  def self.forge weapon
    case weapon
    when :greatsword
      self.new weapon, :str, '2d6', great: true
    when :light_crossbow
      self.new weapon, :dex, '1d8', ranged: true
    when :mace
      self.new weapon, :str, '1d6'
    when :greataxe
      self.new weapon, :str, '1d12', great: true
    when :shortsword
      self.new weapon, :dex, '1d6', finesse: true
    end
  end

  def weapon
    true
  end

  def evaluate
    target = choose_target
    evaluate_target target
  end

  def perform
    target = choose_target
    character.engage target unless ranged
    hit, crit = roll_to_hit target, check_for_disadvantage
    if hit
      damage = damage_dice.roll(crit, gwf: gwf) + damage_bonus
      sneaking = sneaking? target
      damage += sneak_attack.roll(crit) if sneaking
      p "#{"#{character.name} sneak attacks! " if sneaking}#{"#{character.name} crits! " if crit}#{character.name} deals #{damage} damage to #{target.name} with a #{name}."
      target.take damage
    else
      p "#{character.name} misses #{target.name}."
    end
  end

  private

  def evaluate_target target
    hit_chance = (21 + attack_bonus - target.ac) / 20.0
    hit_chance = hit_chance**2 if check_for_disadvantage == :disadvantage
    damage = damage_dice.average + damage_bonus
    damage = damage * 0.7 if !ranged && !character.melee && !character.engaged
    damage * hit_chance / target.hp
  end

  def sneaking? target
    sneak_attack && target.engaged.count > 0
  end

  def choose_target
    targets = character.foes.select &:standing
    targets = targets.select(&:melee) if targets.any?(&:melee) && !ranged
    targets.max { |a, b| evaluate_target(a) <=> evaluate_target(b) }
  end
end
