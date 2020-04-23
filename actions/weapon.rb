require 'yaml'
require_relative 'action'
require_relative 'attack_bonus'
require_relative 'damage_bonus'
require_relative '../dice'

Weapons = YAML.load(File.read 'weapons.yaml')

class Weapon < Action
  include AttackBonus
  include DamageBonus
  attr_reader :ability, :attack_bonus, :name
  attr_reader :ranged, :great, :light
  attr_accessor :damage_dice
  attr_accessor :sneak_attack, :gwf
  attr_accessor :drawn

  def initialize weapon
    entry = Weapons[weapon]
    @name = weapon
    @ability = entry['ability']&.to_sym
    @damage_dice = Dice(entry['damage'])
    @ranged = entry['ranged'] || false
    @great = entry['great'] || false
    @light = entry['light'] || false
  end

  def weapon?
    true
  end

  def evaluate
    target = choose_target
    evaluate_target target
  end

  def perform
    draw_offhand_weapon if light && character.melee
    target = choose_target
    character.engage target unless ranged
    hit, crit = roll_to_hit target, advantage?
    engage_helper target if character.helped_by
    if hit
      damage = damage_dice.roll(crit, gwf: gwf) + damage_bonus
      damage += sneak_attack_damage target, crit
      p "#{"#{character.name} crits! " if crit}#{character.name} deals #{damage} damage to #{target.name} with a #{name}."
      target.take damage
    else
      p "#{character.name} misses #{target.name}."
    end
  end

  private

  def engage_helper target
    character.helped_by.engage target
    character.helped_by = nil
  end

  def sneak_attack_damage target, crit
    sneaking = sneaking? target
    return 0 if !sneaking
    p "#{character.name} sneak attacks! " if sneaking
    character.sneak_attack_used = true
    sneak_attack.roll(crit)
  end

  def draw_offhand_weapon
    offhand_weapon = Weapon.new name
    character.bonus_actions << offhand_weapon
    ability_bonus = character.send ability
    offhand_weapon.attack_bonus = ability_bonus + character.proficiency_bonus
    offhand_weapon.damage_bonus = 0
    offhand_weapon.character = character
    if offhand_weapon.ability == :dex && character.respond_to?(:sneak_attack)
      offhand_weapon.sneak_attack = character.sneak_attack
    end
  end

  def evaluate_target target
    return evaluate_familiar target if target.familiar?
    hit_chance = (21 + attack_bonus - target.ac) / 20.0
    hit_chance = hit_chance**2 if advantage? == :disadvantage
    hit_chance = 1 - (1 - hit_chance)**2 if advantage? == :advantage
    damage = damage_dice.average + damage_bonus
    damage = damage * 0.7 if !ranged && !character.melee && !character.engaged
    damage * hit_chance / target.current_hp
  end

  def evaluate_familiar target
    target.actions.first.evaluate
  end

  def sneaking? target
    return false if !sneak_attack || character.sneak_attack_used
    return true if target.engaged.count > 0 || advantage?
  end

  def choose_target
    targets = character.foes.select &:standing
    targets = targets.select(&:melee) if targets.any?(&:melee) && !ranged && !character.nimble_escape
    targets.max { |a, b| evaluate_target(a) <=> evaluate_target(b) }
  end
end
