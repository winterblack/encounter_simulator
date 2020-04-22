require_relative 'outcome'

class Encounter
  attr_accessor :round
  attr_reader :characters

  def initialize characters, options={}
    @characters = characters
    @round = 0
    @daylight = options[:daylight]
    assign_allies_and_foes
  end

  def run
    characters.each &:roll_initiative
    print "\nNew Encounter\n"

    binding.pry if round == 0 && over

    until over
      play_round
    end

    if party.none?(&:standing)
      print "\nTPK\n"
    else
      print "\nThe party was victorious. #{party.count(&:dead)} characters died.\n"
    end

    return Outcome.new self
  end

  def play_round
    @round += 1
    print "\nRound #{round}\n"
    characters.sort_by(&:initiative).reverse.each do |character|
      character.take_turn unless character.dead
      break if over
    end
  end

  private

  def party
    @party ||= characters.select(&:pc?)
  end

  def assign_allies_and_foes
    party = characters.select &:pc?
    monsters = characters.reject &:pc?
    characters.each do |character|
      character.allies = character.pc? ? party : monsters
      character.foes = character.pc? ? monsters : party
    end
  end

  def over
    characters.select(&:pc?).none?(&:standing) || characters.reject(&:pc?).none?(&:standing)
  end
end
