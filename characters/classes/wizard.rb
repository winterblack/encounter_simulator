require_relative '../character'
require_relative '../player_character'
require_relative '../spellcaster'

class Wizard < Character
  include PlayerCharacter
  include Spellcaster
  HD_Type = 6
  SpellAbility = :int

  def initialize options
    super(options)
    @melee = options[:melee] || false
    @save_proficiencies = [:int, :wis]
  end
end
