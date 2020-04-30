module CrossbowExpert
  def evaluate_action
    @attacked = true
    value = super
    @attacked = false
    value
  end

  def perform
    @attacked = true unless bonus_action?
    super
    @attacked = false if bonus_action?
  end

  def cannot
    bonus_action? && !@attacked
  end

  def crossbow_expert?
    true
  end
end
