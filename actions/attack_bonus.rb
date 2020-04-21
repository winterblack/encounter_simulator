module AttackBonus
  attr_accessor :attack_bonus

  def roll_to_hit(target, advantage=nil)
    roll = D20.roll advantage
    to_hit = roll + attack_bonus
    hit = roll != 1 && to_hit >= target.ac
    crit = roll == 20
    [hit, crit]
  end

  private

  def check_for_disadvantage
    return :disadvantage if ranged && character.engaged.any?
  end
end
