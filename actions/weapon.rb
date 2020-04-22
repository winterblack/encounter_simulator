require 'yaml'
require_relative 'action'
require_relative 'attack_bonus'
require_relative 'damage_bonus'
require_relative '../dice'

Weapons = YAML.load(File.read 'weapons.yaml')

class Weapon < Action
  include AttackBonus
  include DamageBonus
  attr_reader :ability, :attack_bonus, :name, :ranged, :great
  attr_accessor :damage_dice
  attr_accessor :sneak_attack, :gwf

  def initialize weapon
    entry = Weapons[weapon]
    @name = weapon
    @ability = entry['ability']&.to_sym
    @damage_dice = Dice(entry['damage'])
    @ranged = entry['ranged'] || false
    @great = entry['great']   || false
  end

  def weapon?
    true
  end

  def evaluate
    target = choose_target
    evaluate_target target
  end

  def perform
    target = choose_target
    character.engage target unless ranged
    hit, crit = roll_to_hit target, advantage?
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
    binding.pry if target.nil?
    hit_chance = (21 + attack_bonus - target.ac) / 20.0
    hit_chance = hit_chance**2 if advantage? == :disadvantage
    hit_chance = 1 - (1 - hit_chance**2) if advantage? == :advantage
    damage = damage_dice.average + damage_bonus
    damage = damage * 0.7 if !ranged && !character.melee && !character.engaged
    damage * hit_chance / target.current_hp
  end

  def sneaking? target
    sneak_attack && target.engaged.count > 0
  end

  def choose_target
    targets = character.foes.select &:standing
    targets = targets.select(&:melee) if targets.any?(&:melee) && !ranged && !character.nimble_escape
    targets.max { |a, b| evaluate_target(a) <=> evaluate_target(b) }
  end
end
