require_relative 'encounter'

class Trial
  attr_accessor :outcomes
  attr_reader :characters, :number

  def initialize characters, number
    @characters = characters
    @number = number
    @outcomes = []
  end

  def run
    number.times do
      outcomes << Encounter.new(characters).run
      characters.each(&:reset)
    end
    calculate_averages
  end

  private

  def calculate_averages
    average_spell_slots_used = outcomes.map(&:spell_slots_used).reduce(:+) / number
    average_remaining_hp = outcomes.map(&:remaining_hp).reduce(:+) / number
    average_character_deaths = outcomes.map(&:character_deaths).reduce(:+) / number.to_f
    average_tpks = outcomes.count(&:tpk) / number.to_f
    one_character_death = outcomes.map(&:character_deaths).count(1) / number.to_f
    two_character_death = outcomes.map(&:character_deaths).count(2) / number.to_f
    three_character_death = outcomes.map(&:character_deaths).count(3) / number.to_f
    p "Average spell slots used: #{(average_spell_slots_used * 100).round}%"
    p "Average remaining hp: #{(average_remaining_hp * 100).round}%"
    p "Average TPKs: #{(average_tpks * 100).round}%"
    p "One character death: #{(one_character_death * 100).round}%"
    p "Two character deaths: #{(two_character_death * 100).round}%"
    p "Three character deaths: #{(three_character_death * 100).round}%"
    binding.pry
  end
end
