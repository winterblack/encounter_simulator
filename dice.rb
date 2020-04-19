class Dice
  def initialize expression
    parts = expression.split(/[d+]/).map!(&:to_i)
    @count = parts[0]
    @type = parts[1]
    @bonus = parts[2]
  end

  def roll crit=false
    dice = crit ? @count*2 : @count
    dice.times.collect { rand 1..@type }.reduce(:+) + @bonus
  end

  def average
    (@count + @count * @type)/2 + @bonus
  end
end

class D20
  def self.roll advantage=''
    case advantage
    when 'advantage'
      [rand(1..20), rand(1..20)].max
    when 'disadvantage'
      [rand(1..20), rand(1..20)].min
    else
      rand 1..20
    end
  end
end

def Dice expression
  Dice.new expression
end
