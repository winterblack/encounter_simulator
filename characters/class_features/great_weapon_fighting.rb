module GreatWeaponFighting
  def roll crit=false
    dice = crit ? count * 2 : count
    rolled_dice = dice.times.collect { rand 1..type }
    reroll = rolled_dice.map do |die|
      die < 3 ? rand(1..type) : die
    end

    p "Rolled #{rolled_dice.reduce(:+)} but then used great weapon fighting to get #{reroll.reduce(:+)}."

    reroll.reduce(:+)
  end
end
