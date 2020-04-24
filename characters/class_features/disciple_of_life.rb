module DiscipleOfLife
  private

  def roll_healing
    healing = healing_dice.roll + character.spell_ability_score + 2 + self.class::Level
    p "#{character.name} heals #{target.name} for #{healing}."
    healing
  end

  def average_healing
    super + 2 + self.class::Level
  end
end
