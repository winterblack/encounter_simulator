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
      break if party.none? &:standing
      short_rest
    end
    outcome
  end

  def renew
    AdventuringDay.new encounters.map(&:renew)
  end

  private

  def short_rest
    print "\nThe party takes a short rest.\n"
    party.each &:before_short_rest
    party.each &:short_rest
  end

  def outcome
    print "\nEnd of Adventuring Day\n"
    party.each { |character| p character }
    Outcome.new party, rounds
  end

  def rounds
    outcomes.map(&:rounds).reduce(:+) / outcomes.count
  end
end
