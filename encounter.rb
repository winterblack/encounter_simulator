class Encounter
  attr_reader :monsters, :party
  attr_accessor :round

  def initialize monsters
    @monsters = monsters
    @round = 0
  end

  def run party
    print "\nNew Encounter\n"

    @party = party
    assign_allies_and_foes
    characters.each &:roll_initiative
    play_round until over
  end

  def play_round
    @round += 1

    print "\nRound #{round}\n"

    characters.sort_by(&:initiative).reverse.each do |character|
      character.take_turn unless character.dead
      break if over
    end

    if party.none? &:standing
      print "\nTPK\n"
    else
      print "\nThe party was victorious. #{party.count &:dead} characters died.\n"
    end

  end

  private

  def characters
    @characters ||= monsters + party
  end

  def assign_allies_and_foes
    party.each do |character|
      character.allies = party && character.foes = monsters
    end
    monsters.each do |character|
      character.allies = monsters && character.foes = party
    end
  end

  def over
    party.none?(&:standing) || monsters.none?(&:standing)
  end
end
