class Action
  attr_accessor :character, :name
  attr_reader :target, :value

  def perform
    # required for super
  end

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

  def healing?
    false
  end

  def crossbow_expert?
    false
  end

  def choose_target
    engaged_first(valid_targets).max { |a, b| evaluate_target(a) <=> evaluate_target(b) }
  end

  def evaluate_for_healing
    return 0 if cannot
    @target = choose_target
    return 0 unless target
    @value = evaluate_target(target)
  end

  def start_turn
  end

  def after_encounter
  end

  private

  def engaged_first targets
    targets.sort { |target| target.engaged.any? ? 0 : 1 }
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

  def bonus_action_value
    return 0 if bonus_action?
    character.bonus_actions.select(&:spell?).map(&:evaluate).max || 0
  end

  def evaluate_target target
    return 0 unless target
    @target = target
  end
end
