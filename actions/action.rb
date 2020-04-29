class Action
  attr_accessor :character, :name
  attr_reader :target, :value

  def perform
    @target = choose_target
  end

  def evaluate
    return zero if cannot
    @target = choose_target
    return zero unless target
    @value = evaluate_target(target)
  end

  def evaluate_action
    evaluate + bonus_action_value
  end

  def evaluate_for_healing
    evaluate
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

  def healing?
    false
  end

  def crossbow_expert?
    false
  end

  def start_turn
  end

  def after_encounter
  end

  private

  def choose_target
    valid_targets.max_by { |target| evaluate_target target }
  end

  def bonus_action_value
    character.bonus_actions.map(&:evaluate).max || 0
  end

  def bonus_action?
    character.bonus_actions.include? self
  end

  def zero
    @value = 0
  end

  def cannot
    false
  end

  def evaluate_target target
  end
end
