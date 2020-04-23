module AttackBonus
  attr_accessor :attack_bonus

  def roll_to_hit(target, advantage=nil)
    roll = D20.roll advantage
    to_hit = roll + attack_bonus
    hit = roll != 1 && to_hit >= target.ac
    crit = roll == 20
    [hit, crit]
  end

  def attack?
    true
  end

  private

  def advantage?
    advantage = false
    disadvantage = false

    disadvantage = true if ranged && character.engaged.any?
    advantage = true if character.pack_tactics && character.allies.count > 1
    advantage = true if character.helped_by

    return nil if advantage && disadvantage
    return :advantage if advantage
    return :disadvantage if disadvantage
  end
end
