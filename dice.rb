class Dice
  attr_reader :count, :type

  def initialize expression
    parts = expression.split(/[d]/).map!(&:to_i)
    @count = parts.first
    @type = parts.last
  end

  def roll crit=false, options={}
    dice = crit ? count * 2 : count
    return roll_gwf dice if options[:gwf]
    dice.times.collect { rand 1..type }.reduce(:+)
  end

  def average
    (count + count * type) / 2.0
  end

  private

  def roll_gwf dice
    rolled_dice = dice.times.collect { rand 1..type }
    reroll = rolled_dice.map do |die|
      die < 3 ? rand(1..type) : die
    end
    reroll.reduce(:+)
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
