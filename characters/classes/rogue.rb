require_relative '../player_character'
require_relative '../class_features/sneak_attack'

class Rogue < PlayerCharacter
  HD_Type = 8
  attr_accessor :sneak_attack_used

  def initialize options
    super(options)
    @melee = options[:melee] || false
    @ranged = !melee
    @save_proficiencies = [:dex, :int]
    train_sneak_attack
  end

  def take_turn
    self.sneak_attack_used = false
    super
    self.sneak_attack_used = false
  end

  private

  def train_sneak_attack
    (actions+bonus_actions).select(&:weapon?).each do |weapon|
      weapon.extend SneakAttack if weapon.ability == :dex
    end
  end
end
