class Encounter
  attr_reader :characters
  def initialize characters
    @characters = characters
    prepare_characters
    characters.each &:roll_initiative
  end

  def run
    until over
      play_round
    end
  end

  def play_round
    characters.sort_by(&:initiative).reverse.each do |character|
      break if over
      character.take_turn
    end
  end

  private

  def prepare_characters
    pcs = characters.select &:pc
    monsters = characters.reject &:pc
    characters.each do |character|
      character.allies = character.pc ? pcs : monsters
      character.foes = character.pc ? monsters : pcs
    end
  end

  def over
    characters.select(&:pc).none?(&:standing) || characters.reject(&:pc).none?(&:standing)
  end
end
