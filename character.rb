require_relative 'dice'

class Character
  attr_reader :name, :pc, :actions, :ac, :hp, :melee
  attr_accessor :foes, :allies, :initiative, :current_hp, :dead, :dying,
                :death_saves, :stable, :engaged

  def initialize options={}
    @name = options[:name]
    @initiative_bonus = options[:initiative]
    @pc = options[:pc]
    @actions = options[:actions]
    assign_character_to_actions
    @ac = options[:ac]
    @hp = options[:hp]
    @current_hp = hp
    @melee = options[:melee]
    @death_saves = []
    @engaged = []
    sneak_attack = options[:sneak_attack]
    add_sneak_attack_to_actions sneak_attack if sneak_attack
  end

  def roll_initiative
    self.initiative = D20.roll + @initiative_bonus
    p "#{name} rolled #{initiative} initiative"
  end

  def take_turn
    return if dead
    return roll_death_save if dying
    return p "#{name} is stable." if stable
    action = choose_action
    target = choose_target action
    binding.pry if self.nil? || target.nil? || action.nil?
    p "#{name} attacks #{target.name} with #{action.name}"
    action.perform target
  end

  def take damage
    self.current_hp -= damage
    check_if_dying
  end

  def inspect
    if standing
      "<Character name=#{name} ac=#{ac} hp=#{hp} current_hp=#{current_hp} damage_dealt=#{actions.first.total_damage_dealt}>"
    else
      "<Character name=#{name} #{"death_saves=#{death_saves}" if pc}#{' dying' if dying}#{' stable' if stable}#{' dead' if dead} damage_dealt=#{actions.first.total_damage_dealt}>"
    end
  end

  def standing
    !dead && !dying && !stable
  end

  private

  def assign_character_to_actions
    actions.each { |action| action.character = self }
  end

  def add_sneak_attack_to_actions sneak_attack
    actions.each do |action|
      action.sneak_attack = Dice sneak_attack if action.ranged || action.finesse
    end
  end

  def choose_target action
    targets = foes.select(&:standing)
    targets = targets.select(&:melee) if targets.any?(&:melee) && !action.ranged
    targets.max { |a, b| action.efficacy(a) <=> action.efficacy(b) }
  end

  def choose_action
    actions.first
  end

  def check_if_dying
    if current_hp < 1
      if hp + current_hp > 0 && pc
        self.dying = true
        self.current_hp = 0
        p "#{name} is dying."
      else
        die
      end
    end
  end

  def die
    self.dying = false
    self.stable = false
    self.current_hp = 0
    self.dead = true
    self.engaged.each { |character| character.engaged.delete self }
    self.engaged = []
    p "#{name} is dead"
  end

  def roll_death_save
    roll = D20.roll
    case roll
    when 1
      death_saves << false
      p "#{name} critically failed a death save!"
    when 2..9
      death_saves << false
      p "#{name} failed a death save."
    when 10..19
      death_saves << true
      p "#{name} succeeded a death save."
    when 20
      self.death_saves = []
      self.dying = false
      self.current_hp = 1
      p "#{name} critically succeeded a death save! #{name} is back in the fight."
    end
    if death_saves.count(true) > 2
      self.dying = false
      self.stable = true
      p "#{name} is stable."
    end
    if death_saves.count(false) > 2
      die
    end
  end
end
