require_relative 'outcome'
require_relative 'characters/class_features/familiar'

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

  def count
    1
  end

  private

  def play_round
    increment_round
    characters.sort_by(&:initiative).reverse.each do |character|
      character.take_turn if character.conscious
      break if over
    end
  end

  def increment_round
    @round += 1
    print "\nRound #{round}\n"
  end

  def get_ready
    summon_familiars
    assign_allies_and_foes
    characters.each &:roll_initiative

    print "\n New Encounter #{monsters.map(&:name).join(", ")}\n"
  end

  def characters
    @characters = monsters + party
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

  def summon_familiars
    party.reject!(&:familiar?)
    party.select(&:spellcaster?).select { |pc| pc.spells.include?(:find_familiar) }.each do
      party << Familiar.new
    end
  end

  def over
    party.reject(&:familiar?).none?(&:standing?) || monsters.none?(&:standing?)
  end

  def outcome
    party.reject!(&:familiar?)
    if party.none? &:standing?
      print "\n TPK \n"
    else
      print "\n The party was victorious. #{party.count &:dead} characters died. \n"
    end
    monster_types = monsters.map(&:monster)
    party.each do |character|
      p character
    end
    Outcome.new party, round, monster_types
  end
end
