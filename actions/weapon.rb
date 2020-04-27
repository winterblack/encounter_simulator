require 'yaml'
require_relative 'action'
require_relative 'attack'

class Weapon < Action
  include Attack
  attr_reader :weapon
  attr_accessor :damage_dice, :damage_bonus
  attr_reader :finesse, :great, :light

  Weapons = YAML.load(File.read 'weapons.yaml')

  def initialize weapon
    entry = Weapons[weapon]
    @weapon = weapon
    @name = weapon
    @damage_dice = Dice(entry['damage'])
    @finesse = entry['finesse'] || false
    @ranged = entry['ranged'] || false
    @great = entry['great'] || false
    @light = entry['light'] || false
    @short_range = entry['short range'] || false
  end

  def opportunity_attack target
    @target = target
    roll_to_hit
    @hit ? strike : miss
  end

  def ability
    (ranged || finesse) ? :dex : :str
  end

  def weapon?
    true
  end

  def one_attack_value target
    @target = target
    average_damage * hit_chance / target.current_hp
  end

  private

  def average_damage
    damage_dice.average + damage_bonus
  end

  def strike
    damage = roll_damage
    strike_message damage
    target.take damage
  end

  def roll_damage
    damage_dice.roll(crit) + damage_bonus
  end

  def effects
    super
    draw_offhand_weapon if light && character.melee && character.pc?
  end

  def draw_offhand_weapon
    offhand_weapon = Weapon.new weapon
    character.bonus_actions << offhand_weapon
    ability_bonus = character.send ability
    offhand_weapon.attack_bonus = ability_bonus + character.proficiency_bonus
    offhand_weapon.damage_bonus = 0
    offhand_weapon.character = character
    offhand_weapon
  end
end
