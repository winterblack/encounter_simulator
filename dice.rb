class Dice
  attr_accessor :count
  attr_reader :type

  def initialize expression
    parts = expression.split('d').map(&:to_i)
    @count = parts.first
    @type = parts.last
  end

  def roll crit=false
    dice = crit ? count * 2 : count
    dice.times.collect { rand 1..type }.reduce(:+)
  end

  def average
    (count + count * type) / 2.0
  end
end

class D20
  def self.roll advantage=nil
    case advantage
    when :advantage
      [rand(1..20), rand(1..20)].max
    when :disadvantage
      [rand(1..20), rand(1..20)].min
    else
      rand 1..20
    end
  end
end

def Dice expression
  Dice.new expression
end
