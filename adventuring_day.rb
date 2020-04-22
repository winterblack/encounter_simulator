class AdventuringDay
  attr_reader :encounters, :party

  def initialize encounters, party
    @encounters = encounters
    @party = party
  end

  def adventure
    encounters.each do |encounter|
      encounter.run party
      break if party.none? &:standing

      print "\nThe party takes a short rest.\n"
      party.each &:short_rest
    end

    print "\nEnd of Adventuring Day\n"
    party.each do |character|
      p character
    end
  end
end
