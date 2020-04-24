# Character

def take_turn
  action = choose_action
  action.perform if action.value > 0
  bonus_action = choose_bonus_action
  bonus_action.perform if bonus_action.value > 0
  end_turn
end

private

def choose_action
  actions.max { |a, b| a.evaluate <=> b.evaluate }
end

def end_turn
  # implement on class, for example sneak attack becomes available again
end

# Action

attr_reader :character
attr_accessor :target, :value

def evaluate
  @target = choose_target
  @value = evaluate_target
end

def perform
  # implement on action
end

private

def choose_target
  valid_targets.max { |a, b| evaluate_target(a) <=> evalaute_target(b) }
end

def valid_targets
  # implement on action
end

def evaluate_target
  return 0 unless target
end

# Attack < Action

attr_accessor :attack_bonus

def perform
  @target = choose_target
  effects
  roll_to_hit
  @hit ? hit : miss
end

private

def valid_targets
  targets = character.foes.select &:standing?
  targets = targets.select(&:melee?) if targets.any?(&:melee?)
end

def evaluate_target
  return 0 if super == 0
  average_damage * hit_chance / target.current_hp
end

def average_damage
  #implement on attack
end

def hit_chance
  chance = (21 + attack_bonus - target.ac) / 20.0
  case advantage_disadvantage
  when :advantage then 1 - (1 - chance)**2
  when :disadvantage then chance**2
  else chance
  end
end

def roll_to_hit
  roll = D20.roll advantage_disadvantage
  to_hit = roll + attack_bonus
  @hit = roll != 1 && to_hit >= target.ac
  @crit = roll == 20
end

def effects
  # implement on attack
end

def hit
  # implement on attack
end

def miss
  # miss message
end

# Weapon < Attack

attr_accessor :damage_bonus, :sneak_attack
attr_reader :ranged, :light

private

def average_damage
  damage_dice.average + damage_bonus + sneak_attack_average
end

def sneak_attack_average
  sneaking? ? sneak_attack.average : 0
end

def sneak_attack_damage
  sneaking? ? sneak_attack.roll : 0
end

def sneaking?
  return false if !sneak_attack || character.sneak_attack_used
  advantage_disadvantage == :advantage || target.engaged.count > 0
end

def hit
  damage = damage_dice.roll(@crit, gwf: gwf) + damage_bonus
  damage += sneak_attack_damage if sneaking?
  target.take damage
end

def miss
end

def effects
  draw_offhand_weapon if light && character.melee && character.pc?
  character.engage target unless ranged
  engage_helper if character.helper
end

def draw_offhand_weapon
  character.equip_offhand_weapon(Weapon.new name)
end
