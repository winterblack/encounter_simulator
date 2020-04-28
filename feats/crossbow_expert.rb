module CrossbowExpert
  def bonus_action_value
    spell = super
    return 0 if spell == 0
    crossbow = character.bonus_actions.find(&:crossbow_expert?).evaluate
    [spell, crossbow].max
  end

  def crossbow_expert?
    true
  end
end
