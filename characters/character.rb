require_relative '../actions/weapon'
require_relative '../actions/help'

class Character
  attr_reader :name, :level
  attr_reader :str, :dex, :con, :int, :wis, :cha
  attr_reader :ac, :hp, :proficiency_bonus
  attr_reader :save_proficiencies, :weapons
  attr_accessor :initiative, :current_hp, :melee, :dead
  attr_accessor :allies, :foes, :engaged
  attr_accessor :actions, :bonus_actions
  attr_accessor :helper

  # monster features
  attr_reader :pack_tactics, :nimble_escape

  def initialize
    @actions = [Help.new]
    actions.each { |action| action.character = self }
    @bonus_actions = []
    @engaged = []
  end

  def roll_initiative
    self.initiative = D20.roll + dex
  end

  def take_turn
    print "\nIt's #{name}'s turn.\n"
    $current_turn = self
    action = choose_action
    action.perform if action && action.evaluate > 0
    bonus_action = choose_bonus_action
    bonus_action.perform if bonus_action && bonus_action.evaluate > 0
  end

  def take damage
    self.current_hp -= damage
    check_if_dying
  end

  def heal healing
    max_healing = [hp - current_hp, healing].min
    self.current_hp += max_healing
    p "#{name} gains #{max_healing} hp. #{name} is at #{current_hp} hp."
  end

  def roll_save ability
    if save_proficiencies.include? ability
      D20.roll + send(ability) + proficiency_bonus
    else
      D20.roll + send(ability)
    end
  end

  def engage target
    self.melee = true
    p "#{name} engages #{target.name}."
    self.engaged << target unless self.engaged.include? target
    target.engaged << self unless target.engaged.include? self
  end

  def disengage
    self.engaged.each { |character| character.engaged.delete self }
    self.engaged = []
  end

  def standing?
    current_hp > 0
  end

  def pc?
    false
  end

  def familiar?
    false
  end

  def inspect
    "#<#{self.class} hp=#{current_hp}>"
  end

  private

  def choose_action
    actions.max { |a, b| a.evaluate <=> b.evaluate }
  end

  def choose_bonus_action
    bonus_actions.max { |a, b| a.evaluate <=> b.evaluate }
  end

  def check_if_dying
    die if current_hp < 1
  end

  def die
    self.dead = true
    self.current_hp = 0
    disengage

    p "#{name} dies!"
  end

  def set_proficiency_bonus
    case level
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
      action = Weapon.new weapon
      self.actions << action
      ability_bonus = send action.ability
      action.attack_bonus = ability_bonus + proficiency_bonus
      action.damage_bonus = ability_bonus
      action.character = self
    end
  end
end
