require_relative 'character'
require_relative '../actions/weapons'

class Monster < Character
end

class Orc < Monster
  def initialize options
    super(options)
    @ac = 13
    @hp = 15
    @current_hp = 15
    @actions = [Greataxe.new]
    @str = +3
    @dex = +1
    @con = +3
    @int = -2
    @wis = 0
    @cha = 0
    @proficiency_bonus = +2
    @melee = true
    equip_actions
  end
end
