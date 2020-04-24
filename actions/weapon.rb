require 'yaml'
require_relative 'action'
require_relative 'attack'

class Weapon < Action
  include Attack
  attr_reader :weapon
  attr_accessor :damage_dice, :damage_bonus
  attr_reader :ranged, :finesse, :great, :light

  Weapons = YAML.load(File.read 'weapons.yaml')

  def initialize weapon
    entry = Weapons[weapon]
    @weapon = weapon
    @damage_dice = Dice(entry['damage'])
    @finesse = entry['finesse'] || false
    @ranged = entry['ranged'] || false
    @great = entry['great'] || false
    @light = entry['light'] || false
  end

  def ability
    (ranged || finesse) ? :dex : :str
  end

  def weapon?
    true
  end

  def average_damage
    damage_dice.average + damage_bonus
  end

  private

  def valid_targets
    targets = super
    targets.select!(&:melee) if must_target_melee(targets)
    targets
  end

  def must_target_melee targets
    targets.any?(&:melee) && !ranged && !character.nimble_escape
  end

  def strike
    damage = roll_damage
    p crit_message + hit_message(damage)
    target.take damage
  end

  def roll_damage
    damage_dice.roll(crit) + damage_bonus
  end

  def crit_message
    crit ? "#{character.name} crits! " : ""
  end

  def hit_message damage
    "#{character.name} hits #{target.name} for #{damage} damage with #{weapon}."
  end

  def effects
    character.engage target unless ranged
    draw_offhand_weapon if light && character.melee && character.pc?
    character.helper = nil
  end

  def draw_offhand_weapon
    offhand_weapon = Weapon.new weapon
    character.bonus_actions << offhand_weapon
    ability_bonus = character.send ability
    offhand_weapon.attack_bonus = ability_bonus + character.proficiency_bonus
    offhand_weapon.damage_bonus = 0
    offhand_weapon.character = character
    offhand_weapon.bonus_action = true
    offhand_weapon
  end
end
