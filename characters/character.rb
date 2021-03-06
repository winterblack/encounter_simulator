require_relative '../actions/weapon'
require_relative '../actions/help'

class Character
  attr_reader :name, :level
  attr_reader :str, :dex, :con, :int, :wis, :cha
  attr_reader :hp, :proficiency_bonus
  attr_reader :save_proficiencies, :weapons
  attr_reader :initiative
  attr_accessor :ac
  attr_accessor :current_hp, :melee, :dead, :reaction_used, :unconscious
  attr_accessor :allies, :foes, :engaged
  attr_accessor :actions, :bonus_actions, :reactions
  attr_accessor :helper, :glowing, :forward
  attr_accessor :concentrating_on, :spell_effects

  # monster features
  attr_reader :pack_tactics, :nimble_escape, :aggressive

  def initialize
    @actions = []
    @bonus_actions = []
    @reactions = []
    @engaged = []
    @spell_effects = []
  end

  def roll_initiative
    @initiative = D20.roll + dex
    @actions.reverse!
  end

  def take_turn

    print "\nIt's #{name}'s turn.\n"
    start_turn
    action = choose_action
    binding.pry if action.class == Help && !pc? && !familiar?
    action && action.evaluate > 0 ? action.perform : move_forward
    return unless standing?
    bonus_action = choose_bonus_action
    bonus_action.perform if bonus_action && bonus_action.evaluate > 0
  end

  def move_forward
    return p "#{name} has no valid actions." if forward

    if !melee || actions.map(&:value).max == 0
      p "#{name} moves to get into range."
    end
    self.forward = true
  end

  def take damage
    self.current_hp -= damage
    p "#{name} is at #{current_hp} hp." unless current_hp < 1
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
    current_hp > 0 && !unconscious
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
    return if reaction_used
    return unless target.standing?
    return unless weapon = best_melee_weapon(target)
    weapon.attack target
    self.reaction_used = true
  end

  def opportunity_attack_value target
    return 0 if reaction_used || melee_weapons.none?
    best_melee_weapon(target).value
  end

  def best_melee_weapon target
    melee_weapons.max_by { |weapon| weapon.evaluate_attack target }
  end

  def start_turn
    self.reaction_used = false
    (actions+bonus_actions+reactions).each(&:start_turn)
  end

  def long_range
    !melee && !forward
  end

  def striking_distance
    melee || forward
  end

  def trigger_attack_reaction attack
    reaction = reactions.max_by { |reaction| reaction.evaluate(attack) }
    reaction.perform if reaction && reaction.value > 0
  end

  def conscious
    !dead && !unconscious
  end

  private

  def melee_weapons
    actions.select(&:weapon?).reject(&:ranged)
  end

  def choose_action
    actions.max_by { |action| action.evaluate_action }
  end

  def choose_bonus_action
    bonus_actions.max_by { |ba| ba.evaluate }
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
