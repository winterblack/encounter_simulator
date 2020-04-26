require_relative 'spell'

class Sleep < Action
  include Spell
  attr_reader :targets
  Level = 1

  def evaluate
    return zero if cannot
    @targets = targets
    return zero if targets.none?
    @value = evaluate_targets
    worth_spell_slot
  end

  def perform
    super
    put_fuckers_to_sleep
  end

  private

  def put_fuckers_to_sleep
    sleep_total = sleep_dice.roll
    p "#{character.name} rolls #{sleep_total}."
    targets.each do |target|
      sleep_total -= target.current_hp
      sleep_total >= 0 ? sleep(target) : break
    end
  end

  def sleep target
    target.current_hp = 0
    p "#{target.name} falls asleep!"
  end

  def sleep_dice
    @sleep_dice ||= Dice '5d8'
  end

  def targets
    @targets ||= character.foes.select(&:standing?).sort_by(&:current_hp)
  end

  def evaluate_targets
    return 0 if targets.map(&:current_hp).sum < 11
    value = 0
    targets.count.times do |i|
      value += sleep_chance i
    end
  end

  def sleep_chance i
    hp = targets[0..i].map(&:current_hp).sum
    total_chance hp
  end

  def total_chance total
    case total
    when  5 then 1
    when  7 then 0.9998
    when  8 then 0.9994
    when  9 then 0.9983
    when 10 then 0.9962
    when 11 then 0.9923
    when 12 then 0.9859
    when 13 then 0.9758
    when 14 then 0.9609
    when 15 then 0.9398
    when 16 then 0.9116
    when 17 then 0.8752
    when 18 then 0.8304
    when 19 then 0.7770
    when 20 then 0.7156
    when 21 then 0.6477
    when 22 then 0.5751
    when 23 then 0.5000
    when 24 then 0.4249
    when 25 then 0.3523
    when 26 then 0.2844
    when 27 then 0.2230
    when 28 then 0.1696
    when 29 then 0.1248
    when 30 then 0.0884
    when 31 then 0.0602
    when 32 then 0.0391
    when 33 then 0.0242
    when 34 then 0.0141
    when 35 then 0.0077
    when 36 then 0.0038
    when 37 then 0.0017
    when 38 then 0.0006
    when 39 then 0.0002
    else 0
    end
  end

  def valid_targets
    []
  end
end
