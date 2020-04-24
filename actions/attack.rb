module Attack
  attr_accessor :attack_bonus
  attr_reader :crit

  def perform
    @target = choose_target
    roll_to_hit
    @hit ? strike : miss
    effects
  end

  def attack?
    true
  end

  private

  def valid_targets
    character.foes.select &:standing?
  end

  def evaluate_target target
    super
    average_damage * hit_chance / target.current_hp
  end

  def hit_chance
    chance = (21 + attack_bonus - target.ac) / 20.0
    case advantage_disadvantage
    when nil then chance
    when :advantage then 1 - (1 - chance)**2
    when :disadvantage then chance**2
    end
  end

  def advantage_disadvantage
    advantage, disadvantage = false, false
    disadvantage = true if ranged && character.engaged.any?
    advantage = true if character.pack_tactics && character.allies.count > 1

    return nil if advantage && disadvantage
    return :advantage if advantage
    return :disadvantage if disadvantage
  end

  def roll_to_hit
    roll = D20.roll advantage_disadvantage
    to_hit = roll + attack_bonus
    @hit = roll != 1 && to_hit >= target.ac
    @crit = roll == 20
  end

  def miss
    p "#{character.name} missed!"
  end
end
