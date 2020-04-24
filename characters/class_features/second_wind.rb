require_relative '../../actions/action'

class SecondWind < Action
  def evaluate
    return zero if unavailable
    healing = [average_healing, character_hp - character.current_hp].min
    @value = healing / character_hp.to_f
  end

  def perform
    return if unavailable
    healing = healing_dice.roll + fighter_level
    character.heal(healing)
    character.second_wind_used = true

    p "#{character.name} uses Second Wind! #{character.name} gains #{healing} hp. #{character.name} is at #{character.current_hp}."
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