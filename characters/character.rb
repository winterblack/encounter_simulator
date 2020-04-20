class Character
  attr_reader :str, :dex, :con, :int, :wis, :cha
  attr_reader :name, :pc, :level, :ac, :actions, :hp, :proficiency_bonus
  attr_reader :melee
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
  end

  def roll_initiative
    self.initiative = D20.roll + dex
    p "#{name} rolled #{initiative} initiative."
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

  def equip_actions
    actions.each do |action|
      action.character = self
      ability_bonus = send action.ability
      if action.respond_to? :attack_bonus
        action.attack_bonus = ability_bonus + proficiency_bonus
      end
      if action.respond_to? :damage_bonus
        action.damage_bonus = ability_bonus
      end
    end
  end
end
