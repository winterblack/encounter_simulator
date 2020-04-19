module AttackBonus
  attr_accessor :attack_bonus

  def roll_to_hit target
    roll = D20.roll
    to_hit = roll + attack_bonus
    hit = roll != 1 && to_hit >= target.ac
    crit = roll == 20
    [hit, crit]
  end
end
