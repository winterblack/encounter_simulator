class AdventuringDay
  attr_accessor :encounters, :outcomes
  attr_reader :party

  def initialize encounters
    @encounters = encounters
    @outcomes = []
  end

  def run party
    @party = party
    encounters.each do |encounter|
      outcomes << encounter.run(party)
      break if party.none? &:standing?
      short_rest
    end
    outcome
  end

  def renew
    AdventuringDay.new encounters.map(&:renew)
  end

  def monsters
    encounters.map { |encounter| encounter.monsters.map &:monster }
  end

  def count
    encounters.count
  end

  private

  def short_rest
    print "\nThe party takes a short rest.\n"

    party.select(&:standing?).each &:before_short_rest
    party.select(&:standing?).each &:short_rest
    party.each &:sheath_weapons
  end

  def outcome
    print "\nEnd of Adventuring Day\n"
    party.each { |character| p character }
    Outcome.new party, rounds, monsters
  end

  def rounds
    outcomes.map(&:rounds).reduce(:+) / outcomes.count
  end
end
