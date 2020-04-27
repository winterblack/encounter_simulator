module DiscipleOfLife
  private

  def healing
    super + life_bonus
  end

  def average_healing
    super + life_bonus
  end

  def life_bonus
    2 + self.class::Level
  end
end
