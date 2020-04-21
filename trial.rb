require_relative 'encounter'

class Trial
  attr_accessor :outcomes
  attr_reader :characters, :count

  def initialize characters, count
    @characters = characters
    @count = count
    @outcomes = []
  end

  def run
    count.times do
      outcomes << Encounter.new(characters).run
      characters.map!(&:renew)
    end
    calculate_averages
    self
  end

  def no_death_chance
    no_deaths = outcomes.select { |outcome| outcome.deaths == 0 }.count
    no_deaths / count.to_f
  end

  def tpk_chance
    tpks = outcomes.select { |outcome| outcome.standing == 0 }.count
    tpks / count.to_f
  end

  def calculate_averages
    # average_rounds = (outcomes.map(&:rounds).reduce(:+) / count.to_f).round
    # rounds_min = outcomes.map(&:rounds).min
    # rounds_max = outcomes.map(&:rounds).max
    # average_hp_remaining = outcomes.map(&:remaining_hp).reduce(:+) / count.to_f

    # one_death = outcomes.select { |outcome| outcome.deaths == 1 }.count
    # two_death = outcomes.select { |outcome| outcome.deaths == 2 }.count
    # three_death = outcomes.select { |outcome| outcome.deaths == 3 }.count
    # three_standing = outcomes.select { |outcome| outcome.standing == 3 }.count
    # two_standing = outcomes.select { |outcome| outcome.standing == 2 }.count
    # one_standing = outcomes.select { |outcome| outcome.standing == 1 }.count
    # one_death_chance = one_death / count.to_f
    # two_death_chance = two_death / count.to_f
    # three_death_chance = three_death / count.to_f
    # three_standing_chance = three_standing / count.to_f
    # two_standing_chance = two_standing / count.to_f
    # one_standing_chance = one_standing / count.to_f

    # print "\nAverage rounds: #{average_rounds}"
    # print "\nMinimum rounds: #{rounds_min}"
    # print "\nMaximum rounds: #{rounds_max}"
    # print "\nAverage HP remaining: #{(average_hp_remaining * 100).round(2)}%"

    # print "\nChance of one character death: #{(one_death_chance * 100).round}%\n"
    # print "\nChance of two character deaths: #{(two_death_chance * 100).round}%\n"
    # print "\nChance of three character deaths: #{(three_death_chance * 100).round}%\n"
    # print "\nChance of three characters standing: #{(three_standing_chance * 100).round}%\n"
    # print "\nChance of two characters standing: #{(two_standing_chance * 100).round}%\n"
    # print "\nChance of one character standing: #{(one_standing_chance * 100).round}%\n"

    print "\nClasses: #{characters.map &:class}"
    print "\nChance of no character deaths: #{(no_death_chance() * 100).round(2)}%"
    print "\nChance of TPK: #{(tpk_chance() * 100).round(2)}%\n"
  end
end
