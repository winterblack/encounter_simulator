require_relative '../character'
require_relative '../player_character'
require_relative 'second_wind'

class Fighter < Character
  attr_accessor :second_wind_used
  include PlayerCharacter
  HD_Type = 10

  def initialize options
    super(options)
    @melee = options[:melee] || true
    @save_proficiencies = [:str, :con]

    second_wind = SecondWind.new
    second_wind.character = self
    @bonus_actions = [second_wind]
  end
end
