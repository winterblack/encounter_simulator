class Outcome
  attr_reader :party, :rounds, :monsters

  def initialize party, rounds, monsters
    @party = party
    @rounds = rounds
    @monsters = monsters
  end

  def deaths
    tpk? ? party.count : party.count(&:dead)
  end

  def tpk?
    party.none? &:standing?
  end

  def remaining_hp
    return 0 if tpk?
    total_hp = party.map(&:hp).sum
    total_remaining_hp = party.map(&:current_hp).sum
    total_remaining_hp / total_hp.to_f
  end
end
