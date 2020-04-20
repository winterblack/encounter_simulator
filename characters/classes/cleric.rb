require_relative '../character'
require_relative '../player_character'
require_relative '../spellcaster'

class Cleric < Character
  include PlayerCharacter
  include Spellcaster
  HD_Type = 8
  SpellAbility = :wis

  def initialize options
    super(options)
    @melee = options[:melee] || true
    @save_proficiencies = [:wis, :cha]
  end
end
