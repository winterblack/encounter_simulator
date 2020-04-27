require_relative '../actions/weapon'
require_relative '../actions/help'

class Character
  attr_reader :name, :level
  attr_reader :str, :dex, :con, :int, :wis, :cha
  attr_reader :hp, :proficiency_bonus
  attr_reader :save_proficiencies, :weapons
  attr_accessor :ac
  attr_accessor :initiative, :current_hp, :melee, :dead, :reaction_used
  attr_accessor :allies, :foes, :engaged
  attr_accessor :actions, :bonus_actions, :reactions
  attr_accessor :helper, :glowing, :striking_distance
  attr_accessor :concentrating_on, :spell_effects

  # monster features
  attr_reader :pack_tactics, :nimble_escape, :aggressive

  def initialize
    @actions = [Help.new]
    actions.each { |action| action.character = self }
    @bonus_actions = []
    @reactions = []
    @engaged = []
    @spell_effects = []
  end

  def roll_initiative
    self.initiative = D20.roll + dex
  end

  def take_turn
    print "\nIt's #{name}'s turn.\n"
    start_turn
    action = choose_action
    action.perform if action && action.evaluate > 0
    return unless standing?
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
    p "#{name} engages #{target.name}." unless engaged.include? target
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

  def opportunity_attack target
    return unless target.standing?
    weapon = melee_weapons.max do |weapon|
      weapon.one_attack_value target
    end
    return unless weapon
    p "#{name} makes an opportunity attack against #{target.name}!"
    disengage
    weapon.opportunity_attack target
    self.reaction_used = true
  end

  def opportunity_attack_value target
    return 0 if reaction_used
    melee_weapons.map do |weapon|
      weapon.one_attack_value target
    end.max
  end

  private

  def start_turn
    self.reaction_used = false
    (actions+bonus_actions+reactions).each(&:start_turn)
  end

  def melee_weapons
    actions.select(&:weapon?).reject(&:ranged)
  end

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
