class Outcome
  attr_reader :tpk, :spell_slots_used, :remaining_hp, :character_deaths, :characters
  def initialize characters
    @characters = characters
    @tpk = tpk?
    @spell_slots_used = spell_slots_used?
    @remaining_hp = remaining_hp?
    @character_deaths = party.count(&:dead)
  end

  private

  def party
    @party ||= characters.select &:pc
  end

  def tpk?
    party.none?(&:standing)
  end

  def spell_slots_used?
    return 0 if tpk?
    spellcasters = party.select &:spell_slots
    return 0 if spellcasters.none?
    spell_slots = spellcasters.map &:spell_slots
    spell_slots_remaining = spellcasters.map &:spell_slots_remaining
    total_spell_slots = spell_slots.reduce(0) do |slots, spell_slots|
      slots + spell_slots.values.reduce(:+)
    end
    total_spell_slots_remaining = spell_slots_remaining.reduce(0) do |slots, spell_slots|
      slots + spell_slots.values.reduce(:+)
    end
    (total_spell_slots - total_spell_slots_remaining) / total_spell_slots.to_f
  end

  def remaining_hp?
    return 0 if tpk?
    total_hp = party.map(&:hp).reduce(:+)
    total_remaining_hp = party.map(&:current_hp).reduce(:+)
    total_remaining_hp / total_hp.to_f
  end
end
