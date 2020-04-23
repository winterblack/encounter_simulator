class Action
  attr_accessor :character

  def weapon?
    false
  end

  def save?
    false
  end

  def spell?
    false
  end

  def spell_attack?
    false
  end

  def attack?
    false
  end
end
