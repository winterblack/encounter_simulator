require_relative '../player_character'
require_relative '../spellcaster'
require_relative '../class_features/disciple_of_life'

class Cleric < PlayerCharacter
  include Spellcaster
  HD_Type = 8
  SpellAbility = :wis

  def initialize options
    super(options)
    @melee = options[:melee] || true
    @ranged = !melee
    @save_proficiencies = [:wis, :cha]
    @domain = options[:domain]
    train_domains
  end

  private

  def memorize_spells
    spells.each do |spell|
      case spell
      when :bless then self.actions << Bless.new
      when :cure_wounds then self.actions << CureWounds.new
      when :guiding_bolt then self.actions << GuidingBolt.new
      when :healing_word then self.bonus_actions << HealingWord.new
      when :shield_of_faith then self.bonus_actions << ShieldOfFaith.new
      end
    end
    super
  end

  def train_domains
    memorized_spells.select(&:healing?).each do |spell|
      spell.extend DiscipleOfLife
    end
  end
end
