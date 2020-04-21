require_relative '../actions/weapon'

class Character
  attr_reader :str, :dex, :con, :int, :wis, :cha
  attr_reader :name, :pc, :level, :ac, :actions, :hp, :proficiency_bonus
  attr_reader :melee, :save_proficiencies, :bonus_actions, :weapons
  attr_accessor :initiative, :allies, :foes, :current_hp, :dead
  attr_accessor :engaged

  def initialize options={}
    @options = options
    @name = options[:name]
    @level = options[:level]
    @ac = options[:ac]
    @str = options[:str] || 0
    @dex = options[:dex] || 0
    @con = options[:con] || 0
    @int = options[:int] || 0
    @wis = options[:wis] || 0
    @cha = options[:cha] || 0
    @weapons = options[:weapons] || []
    @actions = []
    @bonus_actions = []
    @engaged = []
    @save_proficiencies = []
  end

  def roll_initiative
    self.initiative = D20.roll + dex
  end

  def roll_save ability
    if save_proficiencies.include? ability
      D20.roll + send(ability) + proficiency_bonus
    else
      D20.roll + send(ability)
    end
  end

  def take_turn
    action = choose_action
    binding.pry if !action
    action.perform
    return if foes.none?(&:standing)
    bonus_action = choose_bonus_action
    bonus_action.perform if bonus_action && bonus_action.evaluate > 0
  end

  def take damage
    self.current_hp -= damage
    p "#{name} has #{current_hp} hp remaining" if current_hp > 0
    check_if_dead unless pc
  end

  def heal healing
    self.current_hp += healing
    self.current_hp = hp if current_hp > hp
    p "#{name} was healed for #{healing}. #{name} is at #{current_hp} hp."
  end

  def standing
    !dead
  end

  def inspect
    "<#{name} hp=#{current_hp}#{' dead' if dead}>"
  end

  def renew
    self.class.new @options
  end

  def choose_action
    actions.max { |a, b| a.evaluate <=> b.evaluate }
  end

  def over
    allies.none?(&:standing) || foes.none?(&:standing)
  end

  private

  def choose_bonus_action
    bonus_actions.max { |a, b| a.evaluate <=> b.evaluate }
  end

  def check_if_dead
    die if current_hp < 1
  end

  def die
    self.dead = true
    self.current_hp = 0
    self.engaged.each { |character| character.engaged.delete self }
    self.engaged = []
    p "#{name} dies!"
  end

  def forge_weapons
    weapons.each do |weapon|
      self.actions << Weapon.forge(weapon)
    end
  end

  def equip_weapons
    actions.select(&:weapon).each do |weapon|
      ability_bonus = send weapon.ability
      weapon.attack_bonus = ability_bonus + proficiency_bonus
      weapon.damage_bonus = ability_bonus
    end
  end

  def assign_self_to_actions
    actions.each { |action| action.character = self }
    bonus_actions.each { |action| action.character = self }
  end
end
