require_relative 'action'

class Help < Action
  def evaluate
    ally = choose_ally
    evaluate_ally ally
  end

  def perform
    ally = choose_ally
    ally.helper = character
    p "#{character.name} helps #{ally.name}."
  end

  private

  def choose_ally
    allies = character.allies.select(&:pc?).select(&:standing?)
    allies.max { |a, b| evaluate_ally(a) <=> evaluate_ally(b) }
  end

  def evaluate_ally ally
    return 0 if !ally
    return 0 if ally.helper
    attack = ally.actions.select(&:attack?).max do |a, b|
      a.evaluate <=> b.evaluate
    end
    damage = attack.damage_dice.average + attack.damage_bonus
    damage += ally.sneak_attack.average if ally.sneak_attack
    target = ally.foes.min { |a, b| a.current_hp <=> b.current_hp }
    hit_chance = (21 + attack.attack_bonus - target.ac) / 20.0
    advantage = 1 - (1 - hit_chance)**2
    damage * (advantage - hit_chance) / target.current_hp
  end
end
