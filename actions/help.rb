require_relative 'action'

class Help < Action
  def perform
    binding.pry if cannot
    choose_target.helper = character
    p "#{character.name} helps #{target.name}."
  end

  private

  def valid_targets
    character.allies.select(&:standing?)
  end

  def evaluate_target ally
    return 0 if !ally
    return 0 if ally.helper
    attack = ally.actions.select(&:attack?).max do |a, b|
      a.evaluate <=> b.evaluate
    end
    return 0 unless attack && attack.evaluate > 0
    return 0 if attack.advantage_disadvantage == :advantage
    damage = attack.average_damage
    hit_chance = attack.hit_chance
    advantage = 1 - (1 - hit_chance)**2
    target = attack.choose_target
    damage * (advantage - hit_chance) / target.current_hp.to_f
  end
end
