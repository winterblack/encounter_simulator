class Outcome
  attr_reader :party, :rounds

  def initialize party, rounds
    @party = party
    @rounds = rounds
  end

  def deaths
    tpk? ? party.count : party.count(&:dead)
  end

  def tpk?
    party.none? &:standing
  end

  def remaining_hp
    return 0 if tpk?
    total_hp = party.map(&:hp).reduce(:+)
    total_remaining_hp = party.map(&:current_hp).reduce(:+)
    total_remaining_hp / total_hp.to_f
  end
end
