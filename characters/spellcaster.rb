require 'require_all'
require_relative 'character'
require_all 'actions/spells'

module Spellcaster
  attr_accessor :spell_slots, :spell_slots_remaining
  attr_reader :spell_ability, :spell_ability_score, :spells
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
    @spells = options[:spells]
    memorize_spells
    set_spell_attack_bonus
    set_spell_save_dc
    set_spell_slots
  end

  private

  def set_spell_attack_bonus
    attack_bonus = spell_ability_score + proficiency_bonus
    actions.select(&:spell_attack).each do |spell|
      spell.attack_bonus = attack_bonus
    end
  end

  def set_spell_save_dc
    save_dc = 8 + proficiency_bonus + spell_ability_score
    actions.select(&:save).each do |spell|
      spell.save_dc = save_dc
    end
  end

  def set_spell_slots
    self.spell_slots = SPELL_SLOTS_BY_LEVEL[level].clone
    self.spell_slots_remaining = SPELL_SLOTS_BY_LEVEL[level].clone
  end

  def memorize_spells
    self.actions << BurningHands.new if spells.include? :burning_hands
    self.actions << ShockingGrasp.new if spells.include? :shocking_grasp
    self.bonus_actions << HealingWord.new if spells.include? :healing_word
    actions.each { |action| action.character = self }
    bonus_actions.each { |action| action.character = self }
  end
end
