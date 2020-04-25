require 'require_all'
require_all 'actions/spells'

module Spellcaster
  attr_accessor :spell_slots, :spell_cast_this_turn
  attr_reader :spell_ability_score, :spells
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
    set_spell_slots
    set_spell_attack_bonus
    set_spell_save_dc
  end

  def take_turn
    super
    self.spell_cast_this_turn = false
  end

  def spellcaster?
    true
  end

  def inspect
    "#<#{self.class} hp=#{current_hp} hit_dice=[#{hit_dice_string}] spell_slots=#{spell_slots[1..-1]}#{" death_saves=#{death_saves}" unless standing?}#{' dead' if dead}#{' dying' if dying}#{' stable' if stable}>"
  end


  private

  def memorize_spells
    (actions+bonus_actions).each { |action| action.character = self }
  end

  def memorized_spells
    (actions+bonus_actions).select(&:spell?)
  end

  def set_spell_slots
    self.spell_slots = SpellSlotsByLevel[level].dup
  end

  def set_spell_attack_bonus
    attack_bonus = spell_ability_score + proficiency_bonus
    actions.select(&:spell?).select(&:attack?).each do |spell|
      spell.attack_bonus = attack_bonus
    end
  end

  def set_spell_save_dc
    save_dc = 8 + proficiency_bonus + spell_ability_score
    actions.select(&:spell?).select(&:save?).each do |spell|
      spell.save_dc = save_dc
    end
  end
end
