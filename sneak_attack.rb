require_relative 'attack'

class SneakAttack < Attack
  attr_reader :sneak_attack

  def sneak_attack= dice
    @sneak_attack = Dice dice
  end

  def perform character, target
    hit, crit = roll_to_hit target
    sneaking = sneaking? target
    if hit
      damage = damage_dice.roll crit
      sneak_attack_damage = sneaking ? sneak_attack.roll crit : 0
      p "#{character.name + ' crits! ' if crit}#{target.name} takes #{damage} damage from #{character.name}."
      target.take(damage + sneak_attack_damage)
    else
      p "#{character.name} misses #{target.name}."
    end
  end

  private

  def sneaking?
    target.engaged.count > 0
  end
end
