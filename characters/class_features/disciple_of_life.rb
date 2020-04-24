module DiscipleOfLife
  private

  def roll_healing
    super + 2 + self.class::Level
  end

  def average_healing
    super + 2 + self.class::Level
  end
end
