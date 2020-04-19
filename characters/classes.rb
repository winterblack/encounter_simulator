require_relative 'character'
require_relative 'player_character'

class Spellcaster < Character
  def initialize options
    super(options)
    set_spell_attack_bonus
    set_spell_save_dc
    set_spell_slots
  end

  private

  def set_spell_attack_bonus
  end

  def set_spell_save_dc
  end

  def set_spell_slots
  end
end

class Cleric < Spellcaster
  include PlayerCharacter
  HD_TYPE = 8

  def initialize options
    super(options)
    @melee = options[:melee] || true
    @save_proficiencies = [:wis, :cha]
    @spell_ability = :wis
  end

end

class Fighter < Character
  include PlayerCharacter
  HD_TYPE = 10

  def initialize options
    super(options)
    @melee = options[:melee] || true
    @save_proficiencies = [:str, :con]
  end
end

class Rogue < Character
  include PlayerCharacter
  HD_TYPE = 8

  def initialize options
    super(options)
    @melee = options[:melee] || false
    @save_proficiencies = [:dex, :int]
    set_sneak_attack
  end

  private

  def set_sneak_attack
  end
end

class Wizard < Spellcaster
  include PlayerCharacter
  HD_TYPE = 6

  def initialize options
    super(options)
    @melee = options[:melee] || false
    @save_proficiencies = [:int, :wis]
    @spell_ability = :int
  end
end
