require_relative 'spell'

class Bless < Action
  include Spell
  attr_reader :targets
  Level = 1

  def evaluate
    return zero if cannot
    @targets = choose_targets
    return zero if targets.none?
    @value = evaluate_targets
    worth_spell_slot
  end

  def perform
    super
    @targets = choose_targets
    targets.each do |target|
      target.actions.select(&:attack?).each(&:bless)
      target.spell_effects << self
    end

    p "#{targets.map(&:name).join(' and ')} are blessed."
  end

  def concentration?
    true
  end

  def after_encounter
    drop_concentration if character.concentrating_on == self
  end

  def drop_concentration
    super
    targets.each do |target|
      target.actions.select(&:attack?).each do |attack|
        attack.blessed = false
        target.spell_effects.delete self
      end
    end
  end

  private

  def choose_targets
    allies = character.allies.select(&:standing?)
    allies.sort_by { |ally| highest_damage(ally) }.last(3)
  end

  def highest_damage ally
    actions = ally.actions
    attacks = actions.select(&:attack?)
    return 0 if attacks.any?(:blessed?)
    return attacks.map(&:average_damage).max if ally == character
    action = actions.max_by { |action| action.evaluate }
    action.attack? ? action.average_damage : 0
  end

  def evaluate_targets
    hp = character.foes.map(&:current_hp).sum
    return 0 if hp == 0
    damage = targets.map{ |ally| highest_damage(ally) }.sum
    damage > hp ? 0 : damage * 0.125
  end

  def valid_targets
    []
  end
end
