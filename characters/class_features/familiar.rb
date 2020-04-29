require_relative '../character'
require_relative '../../actions/help'

class Familiar < Character
  def initialize
    super
    @name = 'Familiar'
    @ac = 13
    @hp = 1
    @current_hp = 1
    @str = -3
    @dex = +3
    @con = -1
    @int = -4
    @wis = +2
    @cha = -2
    @forward = true
  end

  def familiar?
    true
  end

  def ranged
    true
  end

  def die
    allies.each { |ally| ally.allies.delete self }
    foes.each { |foe| foe.foes.delete self }
    p "Familiar vanishes."
  end

  def before_short_rest
  end

  def short_rest
  end

  def sheath_weapons
  end
end
