module DiscipleOfLife
  private

  def roll_healing
    healing = super + life_bonus
    p "#{character.name} heals #{target.name} for #{healing}."
    healing
  end

  def average_healing
    super + life_bonus
  end

  def life_bonus
    2 + self.class::Level
  end
end
