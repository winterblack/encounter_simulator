require_relative 'dice'

class Attack
  attr_accessor :character, :total_damage_dealt, :sneak_attack
  attr_reader :name, :attack_bonus, :damage_dice, :ranged, :finesse

  def initialize name, attack_bonus, damage, options={ ranged: false, finesse: false }
    @name = name
    @attack_bonus = attack_bonus
    @damage_dice = Dice damage
    @ranged = options[:ranged]
    @total_damage_dealt = 0
  end

  def perform target
    engage target unless ranged
    hit, crit = roll_to_hit target
    if hit
      damage = damage_dice.roll crit
      sneak = sneak_attack_damage crit, target
      p "#{crit_message crit}#{sneak_message target}#{target.name} takes #{damage + sneak} damage from #{character.name}."
      target.take damage + sneak
      self.total_damage_dealt += damage + sneak
    else
      p "#{character.name} misses #{target.name}."
    end
  end

  def efficacy target, options={ disadvantage: false}
    hit_chance = (21 + @attack_bonus - target.ac) / 20.0
    hit_chance = hit_chance**2 if options[:disadvantage]
    damage_dice.average * hit_chance / target.hp
  end

  private

  def crit_message crit
    character.name + ' crits! ' if crit
  end

  def sneak_message target
    character.name + ' sneak attacks! ' if sneaking? target
  end

  def roll_to_hit target
    roll = D20.roll
    to_hit = roll + attack_bonus
    hit = roll != 1 && to_hit >= target.ac
    crit = roll == 20
    [hit, crit]
  end

  def sneaking? target
    target.engaged.count > 0 && sneak_attack
  end

  def sneak_attack_damage crit, target
    return 0 unless sneaking? target
    sneak_attack.roll crit
  end

  def engage target
    character.engaged << target unless character.engaged.include? target
    target.engaged << character unless target.engaged.include? character
  end
end
