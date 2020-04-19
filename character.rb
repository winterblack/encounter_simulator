require_relative 'dice'

class Character
  attr_reader :name, :pc, :actions, :ac, :hp, :melee
  attr_accessor :foes, :allies, :initiative, :current_hp, :dead, :dying,
                :death_saves, :stable

  def initialize options={}
    @name = options[:name]
    @initiative_bonus = options[:initiative]
    @pc = options[:pc]
    @actions = options[:actions]
    @ac = options[:ac]
    @hp = options[:hp]
    @current_hp = hp
    @death_saves = []
    @melee = options[:melee]
  end

  def roll_initiative
    initiative = D20.roll + @initiative_bonus
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
    action.perform self, target
  end

  def take damage
    self.current_hp -= damage
    check_if_dying
  end

  def inspect
    if death_saves.count > 0
      "<Character name=#{name} death_saves:#{death_saves}#{' dying' if dying}#{' stable' if stable}>"
    elsif dead
      "<Character name=#{name} dead>"
    else
      "<Character name=#{name} ac:#{ac} hp:#{hp} current_hp:#{current_hp}>"
    end
  end

  def standing
    !dead && !dying && !stable
  end

  private

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
        self.dying = false
        self.current_hp = 0
        self.dead = true
        p "#{name} is dead."
      end
    end
  end

  def roll_death_save
    roll = D20.roll
    case roll
    when 1
      death_saves << false
    when 2..9
      death_saves << false
    when 10..19
      death_saves << true
    when 20
      self.death_saves = []
      self.dying = false
      self.current_hp = 1
    end
    if death_saves.count(true) > 2
      self.dying = false
      self.stable = true
      p "#{name} is stable."
    end
    if death_saves.count(false) > 2
      self.dying = false
      self.current_hp = 0
      self.dead = true
      p "#{name} is dead."
    end
    p self
  end
end
