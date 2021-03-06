require_relative 'blessing'

module Attack
  include Blessing
  attr_accessor :attack_bonus
  attr_reader :crit, :ranged, :short_range

  def perform
    move
    return unless character.standing?
    attack target
  end

  def attack target
    @target = target
    roll_to_hit
    @hit ? strike : miss
    after_attack
  end

  def evaluate_attack target
    @target = target
    value = evaluate_damage(target) * hit_chance
    @value = [value, 1].min
  end

  def evaluate_damage target
    average_damage / target.current_hp
  end

  def evaluate_advantage
    return 0 if cannot
    @target = choose_target
    return 0 if !target || advantage?
    chance = hit_chance
    advantage = 1 - (1  - chance)**2
    delta = advantage - chance
    value = average_damage * delta / target.current_hp.to_f
    [value, 1].min
  end

  def evaluate_disadvantage
    return 0 if cannot
    @target = choose_target
    return 0 if !target || advantage?
    chance = hit_chance
    delta = chance - chance**2
    value = average_damage * delta / target.current_hp.to_f
    [value, 1].min
  end

  def attack?
    true
  end

  private

  def valid_targets
    targets = character.foes.select(&:standing?)
    targets = targets.select(&:striking_distance) unless can_attack_long_range
    targets = engaged_first(targets)
  end

  def can_attack_long_range
    ranged || character.forward || character.aggressive
  end

  def evaluate_target target
    return 0 if target.familiar?
    evaluate_attack(target) - evaluate_risk(target)
  end

  def hit_chance
    chance = (21 + attack_bonus - target.ac) / 20.0
    chance = [chance, 0.95].min
    case advantage_disadvantage
    when nil then chance
    when :advantage then 1 - (1 - chance)**2
    when :disadvantage then chance**2
    end
  end

  def evaluate_risk target
    return evaluate_aggressive if aggressive?
    return 0 unless provoke?
    values = character.engaged.map do |foe|
      foe.opportunity_attack_value character
    end
    values.sum
  end

  def evaluate_aggressive
    melee_foes.map { |foe| foe.opportunity_attack_value character }.sum
    # weakest_melee_foe.opportunity_attack_value character
  end

  def aggressive?
    !ranged && target.long_range && !character.forward
  end

  def engaged_first targets
    targets.sort { |target| target.engaged.any? ? 0 : 1 }
  end

  def move
    provoke_move if provoke?
    aggressive_move if aggressive?
    nimble_escape if nimble_escape?
    character.engage target unless ranged
    character.helper.engage target if character.helper
  end

  def provoke?
    !character.nimble_escape && _provoke?
  end

  def provoke_move
    character.engaged.reject(&:reaction_used).each do |foe|
      foe.opportunity_attack character
    end
    character.disengage
  end

  def aggressive_move
    p "#{character.name} is aggressive!"
    # weakest_melee_foe.opportunity_attack character
    melee_foes.each do |foe|
      foe.opportunity_attack character
    end
  end

  def melee_foes
    character.foes.select(&:standing?).select(&:melee)
  end

  def weakest_melee_foe
    character.foes.reject(&:familiar?).select(&:standing?).select(&:melee).min_by do |foe|
      foe.opportunity_attack_value character
    end
  end

  def _provoke?
    return false if ranged || character.engaged.none?
    !character.engaged.include?(target)
  end

  def nimble_escape
    p "Nimble escape! #{character.name} was engaged with #{character.engaged.map(&:name).join(' and ')}"
    character.disengage
  end

  def nimble_escape?
    _provoke? && !provoke?
  end

  def long_range?
    short_range && target.long_range && !character.forward
  end

  def roll_to_hit
    attack_messages
    roll = to_hit_roll
    to_hit = roll + attack_bonus
    target.trigger_attack_reaction self
    @hit = roll != 1 && to_hit >= target.ac
    @crit = roll == 20
  end

  def attack_messages
    p "#{character.name} fires at long range!" if long_range?
    p "Pack tactics!" if pack_tactics?
    p "#{character.name} has #{advantage_disadvantage}." if advantage_disadvantage
  end

  def to_hit_roll
    D20.roll advantage_disadvantage
  end

  def strike
    damage = roll_damage
    crit_message + strike_message(damage)
    target.take damage
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
    return true if long_range?
    return false if crossbow_expert?
    return true if ranged && character.engaged.any?
  end

  def pack_tactics?
    character.pack_tactics && (target.engaged - [character]).any?
  end

  def after_attack
    target.glowing = false
    character.helper = nil
    character.move_forward if move_forward?
  end

  def move_forward?
    long_range? || (!ranged && !character.forward)
  end

  def miss
    p "#{character.name} attacks #{target.name} and misses with a #{name}."
  end

  def strike_message damage
    p "#{character.name} hits #{target.name} for #{damage} damage with a #{name}."
  end

  def crit_message
    crit ? "#{character.name} crits! " : ""
  end
end
