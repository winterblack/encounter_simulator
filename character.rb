require_relative 'dice'

class Character
  attr_accessor :foes, :engaged, :current_hp, :dead, :dying
  attr_reader :ac, :hp, :actions

  def initialize(options={})
    @hp = options[:hp]                 || 8
    @ac = options[:ac]                 || 10
    @initiative = options[:initiative] || 0
    @actions = options[:actions]       || []
    @pc = options[:pc]                 || true
    @melee = options[:melee]           || true

    @current_hp = @hp
    @engaged = []
    @dead = false
    @dying = false
    @stable = false
    @death_saves = []
  end

  def roll_initiative
    D20.roll + @initiative
  end

  def take_turn
    return roll_death_save if dying
    action, target = choose_action
    action.perform target
  end

  def take damage
    self.current_hp = current_hp - damage
    p "you took #{damage} damage!"
    check_if_dying
  end

  private

  def choose_action
    action = nil
    target = nil
    best = 0
    actions.each do |action|
      if action.ranged
        disadvantage = !engaged.empty?
        foes.each do |foe|
          efficacy = action.efficacy foe, disadvantage
          if efficacy > best
            action = action
            target = foe
          end
        end
      else
        foes.select(&:melee).each do |foe|
          efficacy = action.efficacy foe
          if efficacy > best
            action = action
            target = foe
          end
        end
      end
    end
    [action, target]
  end

  def check_if_dying
    if current_hp < 1
      if hp + current_hp < 1
        self.dead = true
      else
        self.dying = true
        self.current_hp = 0
      end
    end
    current_hp
  end
end
