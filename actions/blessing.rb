module Blessing
  attr_accessor :blessed

  def blessing_die
    @blessing_die ||= Dice '1d4'
  end

  def to_hit_roll
    blessed ? super + blessing_die.roll : super
  end

  def bless
    @blessed = true
  end

  def hit_chance
    chance = (23.5 + attack_bonus - target.ac) / 20.0
    chance = [chance, 0.95].min
    case advantage_disadvantage
    when nil then chance
    when :advantage then 1 - (1 - chance)**2
    when :disadvantage then chance**2
    end
  end
end
