require_relative 'encounter'
require_relative 'adventuring_day'

class Trial
  attr_reader :scenerio, :count
  attr_accessor :outcomes, :party

  def initialize scenerio, count
    @scenerio = scenerio
    @count = count
    @outcomes = []
  end

  def run party
    count.times do
      @party = party.map(&:renew)
      outcomes << scenerio.renew.run(@party)
    end
    outcome
  end

  def death_chance deaths
    outcomes.map(&:deaths).count(deaths) / count.to_f
  end

  def tpk_chance
    outcomes.count(&:tpk?) / count.to_f
  end

  def average_rounds
    (outcomes.map(&:rounds).reduce(:+) / count.to_f).round
  end

  def average_hp_remaining
    outcomes.map(&:remaining_hp).reduce(:+) / count.to_f
  end

  def outcome
    print "\n Ran the scenerio #{count} times."
    print "\n Party: #{party.map &:class}"
    print "\n Monsters: #{outcomes.last.monsters}"
    print "\n Average rounds: #{average_rounds}"
    print "\n Average remaining hp: #{percent average_hp_remaining}"
    print "\n Chance of zero deaths: #{percent(death_chance(0))}"
    print "\n Chance of TPK: #{percent tpk_chance}\n"
    self
  end

  private

  def percent float
    (float * 100).round(2).to_s + '%'
  end
end
