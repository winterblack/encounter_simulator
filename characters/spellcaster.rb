require_relative 'character'

module Spellcaster
  attr_accessor :spell_slots, :spell_slots_remaining
  attr_reader :spell_ability, :spell_ability_score
  SPELL_SLOTS_BY_LEVEL = {
    1  => { 1 => 2 },
    2  => { 1 => 3 },
    3  => { 1 => 4, 2 => 2 },
    4  => { 1 => 4, 2 => 3 },
    5  => { 1 => 4, 2 => 3, 3 => 2 },
    6  => { 1 => 4, 2 => 3, 3 => 3 },
    7  => { 1 => 4, 2 => 3, 3 => 3, 4 => 1 },
    8  => { 1 => 4, 2 => 3, 3 => 3, 4 => 2 },
    9  => { 1 => 4, 2 => 3, 3 => 3, 4 => 3, 5 => 1 },
    10 => { 1 => 4, 2 => 3, 3 => 3, 4 => 3, 5 => 2 },
    11 => { 1 => 4, 2 => 3, 3 => 3, 4 => 3, 5 => 2, 6 => 1 },
    12 => { 1 => 4, 2 => 3, 3 => 3, 4 => 3, 5 => 2, 6 => 1 },
    13 => { 1 => 4, 2 => 3, 3 => 3, 4 => 3, 5 => 2, 6 => 1, 7 => 1 },
    14 => { 1 => 4, 2 => 3, 3 => 3, 4 => 3, 5 => 2, 6 => 1, 7 => 1 },
    15 => { 1 => 4, 2 => 3, 3 => 3, 4 => 3, 5 => 2, 6 => 1, 7 => 1, 8 => 1 },
    16 => { 1 => 4, 2 => 3, 3 => 3, 4 => 3, 5 => 2, 6 => 1, 7 => 1, 8 => 1 },
    17 => { 1 => 4, 2 => 3, 3 => 3, 4 => 3, 5 => 2, 6 => 1, 7 => 1, 8 => 1, 9 => 1 },
    18 => { 1 => 4, 2 => 3, 3 => 3, 4 => 3, 5 => 3, 6 => 1, 7 => 1, 8 => 1, 9 => 1 },
    19 => { 1 => 4, 2 => 3, 3 => 3, 4 => 3, 5 => 3, 6 => 2, 7 => 1, 8 => 1, 9 => 1 },
    20 => { 1 => 4, 2 => 3, 3 => 3, 4 => 3, 5 => 3, 6 => 2, 7 => 2, 8 => 1, 9 => 1 }
  }
  def initialize options
    super(options)
    @spell_ability_score = send self.class::SpellAbility
    set_spell_attack_bonus
    set_spell_save_dc
    set_spell_slots
  end

  def reset
    super
    self.spell_slots_remaining = spell_slots.clone
  end

  private

  def set_spell_attack_bonus
  end

  def set_spell_save_dc
    save_dc = 8 + proficiency_bonus + spell_ability_score
    actions.each do |action|
      action.save_dc = save_dc if action.respond_to? :save_dc
    end
  end

  def set_spell_slots
    self.spell_slots = SPELL_SLOTS_BY_LEVEL[level].clone
    self.spell_slots_remaining = SPELL_SLOTS_BY_LEVEL[level].clone
  end
end
