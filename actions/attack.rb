module Attack
  attr_accessor :attack_bonus
  attr_reader :crit, :ranged, :short_range

  def perform
    @target = choose_target
    trigger_opportunity_attack
    return unless character.standing?
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
    delta = advantage - chance
    value = average_damage * delta / target.current_hp.to_f
    [delta, value].min
  end

  def evaluate_one_attack
    return zero if cannot
    @target = choose_target
    return zero unless target
    @value = evaluate_target(target)
  end

  def evaluate_for_shield
    average_damage / target.current_hp.to_f
  end

  private

  def trigger_opportunity_attack
    trigger_aggressive if character.aggressive
    return nimble_escape if character.nimble_escape
    return if ranged || character.engaged.none?
    return if character.engaged.include? target
    character.engaged.reject(&:reaction_used).each do |foe|
      foe.opportunity_attack(character)
    end
    character.disengage
  end

  def trigger_aggressive
    return if character.striking_distance || target.melee
    valid_foes = character.foes.select(&:melee).select(&:standing?).reject(&:reaction_used).reject(&:familiar?)
    p "#{character.name} is aggressive!" if valid_foes.any?
    valid_foes.each do |foe|
      foe.opportunity_attack(character)
    end
  end

  def nimble_escape
    if character.engaged.any? && !character.engaged.include?(target)
      p "Nimble escape!"
    end
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
    return nil if advantage? && disadvantage?
    return :advantage if advantage?
    return :disadvantage if disadvantage?
  end

  def advantage?
    return true if character.helper
    return true if pack_tactics?
    return true if target.glowing
  end

  def disadvantage?
    return true if ranged && character.engaged.any?
    return true if short_range && !character.striking_distance
  end

  def pack_tactics?
    character.pack_tactics && target.engaged.any?
  end

  def valid_targets
    targets = character.foes.select &:standing?
    targets = targets.select(&:melee) if must_target_melee(targets)
    targets
  end

  def must_target_melee targets
    return false if ranged || character.striking_distance || character.aggressive
    targets.reject(&:familiar?).any?(&:melee)
  end

  def evaluate_target target
    super
    return 0 if target.familiar?
    value = average_damage * hit_chance / target.current_hp
    value = [value, hit_chance].min
    value - evaluate_opportunity_attacks
  end

  def evaluate_opportunity_attacks
    return evaluate_aggressive if evaluate_aggressive?
    return 0 if ranged || character.engaged.none? || character.nimble_escape
    return 0 if character.engaged.include? target
    character.engaged.select(&:standing?).reject(&:familiar?).map do |foe|
      foe.opportunity_attack_value(character)
    end.sum
  end

  def evaluate_aggressive
    character.foes.select(&:melee).select(&:standing?).reject(&:familiar?).map do |foe|
      foe.opportunity_attack_value(character)
    end.sum
  end

  def evaluate_aggressive?
    character.aggressive && !character.striking_distance && !target.melee
  end

  def roll_to_hit
    p "#{character.name} has #{advantage_disadvantage}." if advantage_disadvantage
    roll = D20.roll advantage_disadvantage
    to_hit = roll + attack_bonus
    target.trigger_shield(self) if target.respond_to? :trigger_shield
    @hit = roll != 1 && to_hit >= target.ac
    @crit = roll == 20
  end

  def effects
    character.engage target unless ranged || !target.standing?
    move_forward unless ranged || character.striking_distance
    engage_helper if character.helper
    target.glowing = false if character.glowing
  end

  def move_forward
    character.striking_distance = true
    return if character.foes.all?(&:melee) || character.foes.none?(&:melee)
    p "#{character.name} moved into striking distance."
  end

  def engage_helper
    character.helper.engage(target) if target.standing?
    character.helper = nil
  end

  def miss
    p "#{character.name} attacks #{target.name} and misses with a #{name}."
  end

  def strike_message damage
    p crit_message + hit_message(damage)
  end

  def crit_message
    crit ? "#{character.name} crits! " : ""
  end

  def hit_message damage
    "#{character.name} hits #{target.name} for #{damage} damage with a #{name}."
  end

  # Not used. More effective to just ignore familiar.
  def evaluate_familiar
    target.actions.map(&:evaluate).max * hit_chance
  end
end
