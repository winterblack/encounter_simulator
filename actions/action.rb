class Action
  attr_accessor :character, :bonus_action
  attr_reader :target, :value

  def evaluate
    return zero if cannot
    @target = choose_target
    return zero unless target
    @value = evaluate_target(target) + bonus_action_value
  end

  def attack?
    false
  end

  def weapon?
    false
  end

  def spell?
    false
  end

  def save?
    false
  end

  def choose_target
    valid_targets.max { |a, b| evaluate_target(a) <=> evaluate_target(b) }
  end

  private

  def zero
    @value = 0
  end

  def cannot
    false
  end

  def bonus_action_value
    return 0 if bonus_action
    character.bonus_actions.select(&:spell?).map(&:evaluate).max || 0
  end

  def evaluate_target target
    return 0 unless target
    @target = target
  end
end
