require_relative '../../actions/action'

class SecondWind < Action
  def evaluate
    return zero if cannot
    healing = [average_healing, character.hp - character.current_hp].min
    @value = healing / character.hp.to_f
  end

  def perform
    p "#{character.name} uses Second Wind!"
    healing = healing_dice.roll + fighter_level
    character.heal(healing)
    character.second_wind_used = true
  end

  private

  def fighter_level
    character.level
  end

  def cannot
    character.second_wind_used
  end

  def healing_dice
    Dice '1d10'
  end

  def average_healing
    healing_dice.average + fighter_level
  end
end
