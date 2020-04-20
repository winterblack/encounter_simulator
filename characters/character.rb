class Character
  attr_reader :str, :dex, :con, :int, :wis, :cha
  attr_reader :name, :pc, :level, :ac, :actions, :hp, :proficiency_bonus
  attr_reader :melee, :save_proficiencies
  attr_accessor :initiative, :allies, :foes, :current_hp, :dead
  attr_accessor :engaged

  def initialize options={}
    @name = options[:name]
    @level = options[:level]
    @ac = options[:ac]
    @actions = options[:actions]
    @str = options[:str] || 0
    @dex = options[:dex] || 0
    @con = options[:con] || 0
    @int = options[:int] || 0
    @wis = options[:wis] || 0
    @cha = options[:cha] || 0
    @engaged = []
    @save_proficiencies = []
  end

  def roll_initiative
    self.initiative = D20.roll + dex
    p "#{name} rolled #{initiative} initiative."
  end

  def roll_save ability
    if save_proficiencies.include? ability
      D20.roll + send(ability) + proficiency_bonus
    else
      D20.roll + send(ability)
    end
  end

  def take_turn
    return if dead
    action = choose_action
    action.perform
  end

  def take damage
    self.current_hp -= damage
    check_if_dead unless pc
  end

  def standing
    !dead
  end

  def inspect
    "<#{name} hp=#{current_hp}#{' dead' if dead}>"
  end

  private

  def choose_action
    max_value = 0
    best_action = nil
    actions.each do |action|
      value = action.evaluate
      if value > max_value
        max_value = value
        best_action = action
      end
    end
    best_action
  end

  def check_if_dead
    die if current_hp < 1
  end

  def die
    self.dead = true
    self.current_hp = 0
    self.engaged.each { |character| character.engaged.delete self }
    self.engaged = []
    p "#{name} is dead."
  end

  def equip_weapons
    actions.each { |action| action.character = self }
    actions.select(&:weapon).each do |weapon|
      ability_bonus = send weapon.ability
      weapon.attack_bonus = ability_bonus + proficiency_bonus
      weapon.damage_bonus = ability_bonus
    end
  end
end
