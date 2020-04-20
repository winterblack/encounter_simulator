class Outcome
  attr_reader :encounter, :remaining_hp, :deaths, :standing, :rounds
  def initialize encounter
    @encounter = encounter
    @remaining_hp = remaining_hp?
    @deaths = tpk? ? party.count : party.count(&:dead)
    @standing = party.count(&:standing)
    @rounds = encounter.round
  end

  private

  def party
    @party ||= encounter.characters.select &:pc
  end

  def tpk?
    party.none?(&:standing)
  end

  def remaining_hp?
    return 0 if tpk?
    total_hp = party.map(&:hp).reduce(:+)
    total_remaining_hp = party.map(&:current_hp).reduce(:+)
    total_remaining_hp / total_hp.to_f
  end
end
