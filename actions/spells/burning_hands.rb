require_relative 'spell'

class BurningHands < Action
  include Spell
  include Save
  attr_reader :targets, :damage_roll
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
    @damage_roll = damage_dice.roll
    roll_saves
  end

  private

  def damage_dice
    @damage_dice ||= Dice '3d6'
  end

  def choose_targets
    character.foes.select(&:standing?).min(3) { |foe| foe.current_hp }
  end

  def evaluate_targets
    value = average_damage * count * count / targets.map(&:current_hp).sum
    value = [value, count].min
  end

  def average_damage
    fail_average + success_average
  end

  def fail_average
    average_damage_roll * fail_chance / 2
  end

  def success_average
    average_damage_roll * (1 - fail_chance)
  end

  def average_damage_roll
    @average ||= damage_dice.average
  end

  def fail_chance
    @fail_chance ||= (save_dc - average_dex - 1) / 20.0
  end

  def average_dex
    targets.sum(&:dex) / count
  end

  def count
    targets.count
  end

  def roll_saves
    targets.each do |target|
      if target.roll_save(:dex) < save_dc
        p "#{target.name} burns for #{damage_roll} damage."
        target.take damage_roll
      else
        p "#{target.name} burns for #{damage_roll/2} damage."
        target.take(damage_roll/2)
      end
    end
  end

  def valid_targets
    []
  end
end
