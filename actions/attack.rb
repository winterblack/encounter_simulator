module Attack
  attr_accessor :attack_bonus
  attr_reader :crit, :ranged

  def perform
    @target = choose_target
    roll_to_hit
    @hit ? strike : miss
    effects
  end

  def attack?
    true
  end

  def evaluate_help
    return 0 if cannot
    @target = choose_target
    return 0 if !target || advantage?
    chance = hit_chance
    advantage = 1 - (1  - chance)**2
    average_damage * (advantage - chance) / target.current_hp.to_f
  end

  private

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
    advantage = advantage?

    return nil if advantage && disadvantage
    return :advantage if advantage
    return :disadvantage if disadvantage
  end

  def advantage?
    return true if character.helper
    return true if character.pack_tactics && character.allies.count > 1
    return true if target.glowing
  end

  def valid_targets
    targets = character.foes.select &:standing?
    targets = targets.select(&:melee) if must_target_melee(targets)
    targets
  end

  def must_target_melee targets
    targets.reject(&:familiar?).any?(&:melee) && !ranged && !character.nimble_escape
  end

  def evaluate_target target
    super
    return 0 if target.familiar?
    average_damage * hit_chance / target.current_hp
  end

  def roll_to_hit
    p "#{character.name} has #{advantage_disadvantage}." if advantage_disadvantage
    roll = D20.roll advantage_disadvantage
    to_hit = roll + attack_bonus
    @hit = roll != 1 && to_hit >= target.ac
    @crit = roll == 20
  end

  def effects
    character.engage target unless ranged
    engage_helper if character.helper
    target.glowing = false if character.glowing
  end

  def engage_helper
    character.helper.engage(target) if target.standing?
    character.helper = nil
  end

  def miss
    p "#{character.name} attacks #{target.name} and misses!"
  end

  def strike_message damage
    p crit_message + hit_message(damage)
  end

  def crit_message
    crit ? "#{character.name} crits! " : ""
  end

  def hit_message damage
    "#{character.name} hits #{target.name} for #{damage} damage with #{name}."
  end

  # Not used. More effective to just ignore familiar.
  def evaluate_familiar
    target.actions.map(&:evaluate).max * hit_chance
  end
end
