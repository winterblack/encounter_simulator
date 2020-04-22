require_relative '../actions/weapon'

class Character
  attr_reader :str, :dex, :con, :int, :wis, :cha
  attr_reader :name, :level, :ac, :hp, :proficiency_bonus
  attr_reader :save_proficiencies, :weapons
  attr_accessor :actions, :bonus_actions, :allies, :foes, :engaged
  attr_accessor :initiative, :current_hp, :dead, :melee

  # monster features
  attr_accessor :pack_tactics, :nimble_escape


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
    @weapons = options[:weapons]
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
    action.perform
    return if foes.none?(&:standing)
    bonus_action = choose_bonus_action
    bonus_action.perform if bonus_action && bonus_action.evaluate > 0
  end

  def take damage
    self.current_hp -= damage
    p "#{name} has #{current_hp} hp remaining" if current_hp > 0
    check_if_dead unless pc?
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

  def pc?
    self.class.included_modules.include?(PlayerCharacter)
  end

  def engage target
    self.melee = true
    self.engaged << target unless self.engaged.include? target
    target.engaged << self unless target.engaged.include? self
  end


  def disengage
    self.engaged.each { |character| character.engaged.delete self }
    self.engaged = []
  end

  private

  def choose_action
    actions.max { |a, b| a.evaluate <=> b.evaluate }
  end

  def choose_bonus_action
    bonus_actions.max { |a, b| a.evaluate <=> b.evaluate }
  end

  def check_if_dead
    die if current_hp < 1
  end

  def die
    self.dead = true
    self.current_hp = 0
    disengage
    p "#{name} dies!"
  end

  def set_proficiency_bonus
    case level || challenge
    when 5..8
      @proficiency_bonus = 3
    when 9..12
      @proficiency_bonus = 4
    when 13..16
      @proficiency_bonus = 5
    when 17..20
      @proficiency_bonus = 6
    else
      @proficiency_bonus = 2
    end
  end

  def equip_weapons
    weapons.each do |weapon|
      action = Weapon.new(weapon)
      self.actions << action
      ability_bonus = send action.ability
      action.attack_bonus = ability_bonus + proficiency_bonus
      action.damage_bonus = ability_bonus
      action.character = self
    end
  end
end
