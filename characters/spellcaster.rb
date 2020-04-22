require 'require_all'
require_relative 'character'
require_all 'actions/spells'

module Spellcaster
  attr_accessor :spell_slots, :spell_slots_remaining
  attr_reader :spell_ability, :spell_ability_score, :spells, :domain
  SpellSlotsByLevel = [
    [ 0, 1, 2, 3, 4, 5, 6, 7, 8, 9 ],
    [ 1, 2 ],
    [ 2, 3 ],
    [ 3, 4, 2 ],
    [ 4, 4, 3 ],
    [ 5, 4, 3, 2 ],
    [ 6, 4, 3, 3 ],
    [ 7, 4, 3, 3, 1 ],
    [ 8, 4, 3, 3, 2 ],
    [ 9, 4, 3, 3, 3, 1 ],
    [10, 4, 3, 3, 3, 2 ],
    [11, 4, 3, 3, 3, 2, 1 ],
    [12, 4, 3, 3, 3, 2, 1 ],
    [13, 4, 3, 3, 3, 2, 1, 1 ],
    [14, 4, 3, 3, 3, 2, 1, 1 ],
    [15, 4, 3, 3, 3, 2, 1, 1, 1 ],
    [16, 4, 3, 3, 3, 2, 1, 1, 1 ],
    [17, 4, 3, 3, 3, 2, 1, 1, 1, 1 ],
    [18, 4, 3, 3, 3, 3, 1, 1, 1, 1 ],
    [19, 4, 3, 3, 3, 3, 2, 1, 1, 1 ],
    [20, 4, 3, 3, 3, 3, 2, 2, 1, 1 ]
  ]

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
    self.spell_slots = SpellSlotsByLevel[level].dup
    self.spell_slots_remaining = SpellSlotsByLevel[level].dup
  end

  def memorize_spells
    self.actions << BurningHands.new if spells.include? :burning_hands
    self.actions << ShockingGrasp.new if spells.include? :shocking_grasp
    self.bonus_actions << HealingWord.new if spells.include? :healing_word
    actions.each { |action| action.character = self }
    bonus_actions.each { |action| action.character = self }
  end
end
