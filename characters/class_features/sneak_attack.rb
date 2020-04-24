module SneakAttack
  private

  def sneak_attack_dice
    @sneak_attack_dice ||= Dice.new "#{(character.level+1)/2}d6"
  end

  def average_damage
    super + sneak_attack_average
  end

  def sneak_attack_average
    sneaking? ? sneak_attack_dice.average : 0
  end

  def sneaking?
    return false if character.sneak_attack_used
    advantage_disadvantage == :advantage || target.engaged.count > 0
  end

  def roll_damage
    damage = damage_dice.roll(crit) + damage_bonus + roll_sneak_attack
    p "#{character.name} sneak attacks #{target.name} for #{damage} damage!"
    damage
  end

  def roll_sneak_attack
    return 0 unless sneaking?
    character.sneak_attack_used = true
    sneak_attack_dice.roll crit
  end

  def draw_offhand_weapon
    super.extend SneakAttack
  end
end
