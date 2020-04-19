class Encounter
  def initialize(characters)
    @characters = characters
    assign_characters_to_encounter
  end

  private

  def assign_characters_to_encounter
    @characters.each do |character|
      character.encounter = self
    end
  end
end
