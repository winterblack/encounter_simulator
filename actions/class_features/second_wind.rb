require_relative '../action'

class SecondWind < Action
  def evaluate
    return 0 if unavailable
    healing = [average_healing, character_hp - character.current_hp].min
    healing / character_hp.to_f
  end

  def perform
    return if unavailable
    p "#{character.name} uses Second Wind!"
    character.heal(healing_dice.roll + fighter_level)
    character.second_wind_used = true
  end

  private

  def character_hp
    character.hp
  end

  def fighter_level
    character.level
  end

  def unavailable
    character.second_wind_used
  end

  def healing_dice
    Dice '1d10'
  end

  def average_healing
    healing_dice.average + fighter_level
  end
end
