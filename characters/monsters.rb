require_relative 'character'
require_relative '../actions/weapon'

class Monster < Character
end

class Orc < Monster
  def initialize options
    super(options)
    @ac = 13
    @hp = 15
    @current_hp = 15
    @str = +3
    @dex = +1
    @con = +3
    @int = -2
    @proficiency_bonus = +2
    @melee = true
    @weapons = [:greataxe]
    equip_weapons
  end
end
