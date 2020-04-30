require 'yaml'
require_relative 'character'

class Monster < Character
  attr_reader :monster, :challenge

  Monsters = YAML.load(File.read 'monsters.yaml')

  def initialize monster, name=nil
    super()
    entry = Monsters[monster]
    @monster = monster
    @name = name || "#{monster}"
    @ac = entry['ac']
    @hp = entry['hp']
    @str = entry['str'] || 0
    @dex = entry['dex'] || 0
    @con = entry['con'] || 0
    @int = entry['int'] || 0
    @wis = entry['wis'] || 0
    @cha = entry['cha'] || 0
    @level = entry['challenge']
    @melee = entry['melee']
    @weapons = entry['weapons'] || []
    @save_proficiencies = entry['save_proficiencies'] || []
    @current_hp = hp
    set_proficiency_bonus
    equip_weapons
    entry['features']&.each { |feature| add_feature feature }
  end

  def renew
    Monster.new(monster, name)
  end

  def inspect
    "#<#{name} hp=#{current_hp}#{' dead' if dead}#{' unconscious' if unconscious}>"
  end

  private

  def add_feature feature
    case feature
    when 'pack tactics' then @pack_tactics = true
    when 'nimble escape' then @nimble_escape = true
    when 'aggressive' then @aggressive = true
    when 'brute' then add_brute_to_weapons
    when 'large' then add_large_to_weapons
    end
  end

  def add_brute_to_weapons
    actions.select(&:weapon?).reject(&:ranged).each do |weapon|
      weapon.damage_dice.count += 1
    end
  end

  def add_large_to_weapons
    actions.select(&:weapon?).each do |weapon|
      weapon.damage_dice.count += 1
    end
  end
end
