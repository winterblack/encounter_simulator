require_relative 'outcome'
require_relative 'characters/classes/familiar'

class Encounter
  attr_accessor :monsters
  attr_reader :party, :round

  def initialize monsters
    @monsters = monsters
    @round = 0
  end

  def run party
    @party = party
    get_ready

    play_round until over

    outcome
  end

  def renew
    Encounter.new monsters.map(&:renew)
  end

  private

  def play_round
    increment_round
    characters.sort_by(&:initiative).reverse.each do |character|
      character.take_turn unless character.dead
      break if over
    end
  end

  def increment_round
    @round += 1
    print "\nRound #{round}\n"
  end

  def get_ready
    print "\nNew Encounter\n"
    summon_familiar
    assign_allies_and_foes
    characters.each &:roll_initiative
  end

  def summon_familiar
    party.select(&:familiar?).each { |familiar| party.delete(familiar) }
    party.select { |pc| pc.spells.include?(:find_familiar) }.each do
      party << Familiar.new
    end
  end

  def characters
    @characters ||= monsters + party
  end

  def assign_allies_and_foes
    party.each do |character|
      character.allies = party
      character.foes = monsters
    end
    monsters.each do |character|
      character.allies = monsters
      character.foes = party
    end
  end

  def over
    party.reject(&:familiar?).none?(&:standing) || monsters.none?(&:standing)
  end

  def outcome
    if party.none? &:standing
      print "\nTPK\n"
    else
      print "\nThe party was victorious. #{party.count &:dead} characters died.\n"
    end
    monster_types = monsters.map(&:monster)
    Outcome.new party, round, monster_types
  end
end
