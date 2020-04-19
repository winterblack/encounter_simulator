require_relative 'action'
require_relative 'dice'

class Attack < Action
  attr_reader :damage, :ranged
  def initialize(attack_bonus, damage, options={ ranged:false })
    @attack_bonus = attack_bonus
    @damage = Dice(damage)
    @ranged = options[:ranged]
  end

  def efficacy foe, disadvantage
    hit_chance = (21 + @attack_bonus - foe.ac) / 20.0
    hit_chance = hit_chance**2 if disadvantage
    damage.average * hit_chance / foe.hp
  end

  def perform target
    hit, crit = roll_to_hit target
    if hit
      damage = @damage.roll crit
      target.take damage
    end
  end

  private

  def roll_to_hit target
    roll = D20.roll
    to_hit = D20.roll + @attack_bonus
    hit = to_hit >= target.ac
    p hit ? 'you hit!' : 'you missed!'
    crit = roll == 20
    p 'you crit!' if crit
    [hit, crit]
  end
end
