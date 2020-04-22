require 'yaml'
require_relative 'character'
require_relative '../actions/weapon'

Monsters = YAML.load(File.read 'monsters.yaml')

class Monster < Character
  attr_reader :monster, :challenge

  def initialize monster, name=monster
    entry = Monsters[monster]
    @monster = monster
    @name = name
    @ac = entry['ac']
    @hp = entry['hp']
    @str = entry['str'] || 0
    @dex = entry['dex'] || 0
    @con = entry['con'] || 0
    @int = entry['int'] || 0
    @wis = entry['wis'] || 0
    @cha = entry['cha'] || 0
    @challenge = entry['challenge'] || 1
    @melee = entry['melee'] || true
    @weapons = entry['weapons'] || []
    @current_hp = hp
    @actions = []
    @bonus_actions = []
    @engaged = []
    @save_proficiencies = []
    set_proficiency_bonus
    equip_weapons
    entry['features']&.each { |feature| add_feature feature }
  end

  def renew
    Monster.new(monster, name)
  end

  private

  def add_feature feature
    case feature
    when 'pack tactics'
      self.pack_tactics = true
    when 'nimble escape'
      self.nimble_escape = true
    when 'brute'
      actions.select(&:weapon).reject(&:ranged).each do |weapon|
        weapon.damage_dice.count += 1
      end
    end
  end
end
