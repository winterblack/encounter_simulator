require_relative '../player_character'
require_relative '../spellcaster'

class Wizard < PlayerCharacter
  include Spellcaster
  HD_Type = 6
  SpellAbility = :int
  attr_accessor :arcane_recovery_used, :reactions, :shield, :shield_active

  def initialize options
    super(options)
    @melee = options[:melee] || false
    @ranged = !melee
    @save_proficiencies = [:int, :wis]
  end

  def take_turn
    if self.shield_active
      self.ac -= 5
      self.shield_active = false
    end
    super
  end

  def short_rest
    super
    use_arcane_recovery unless arcane_recovery_used
  end

  def inspect
    "#<#{self.class} hp=#{current_hp} hit_dice=[#{hit_dice_string}] spell_slots=#{spell_slots[1..-1]}#{" arcane_recovery_used" if arcane_recovery_used}#{" death_saves=#{death_saves}" unless standing?}#{' dead' if dead}#{' dying' if dying}#{' stable' if stable}>"
  end

  def trigger_shield attack
    return unless spells.include?(:shield)
    shield.perform if shield.evaluate(attack) > 0
  end

  private

  def use_arcane_recovery
    spell_level = (level + 1) / 2
    if spell_slots[spell_level] < SpellSlotsByLevel[level][spell_level]
      self.spell_slots[spell_level] += 1
      self.arcane_recovery_used = true

      p "#{name} uses arcane recovery! Spell slots: #{spell_slots[1..-1]}"
    end
  end

  def memorize_spells
    spells.each do |spell|
      case spell
      when :burning_hands then self.actions << BurningHands.new
      when :shield then self.shield = Shield.new self
      end
    end
    super
  end
end
