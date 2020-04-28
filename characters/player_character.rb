require 'require_all'
require_relative 'character'
require_all 'feats'

class PlayerCharacter < Character
  attr_accessor :dying, :death_saves, :stable, :hit_dice
  attr_reader :options, :ranged
  attr_reader :feats

  def initialize options
    super()
    @options = options
    @name = options[:name]
    @level = options[:level]
    @ac = options[:ac]
    @str = options[:str] || 0
    @dex = options[:dex] || 0
    @con = options[:con] || 0
    @int = options[:int] || 0
    @wis = options[:wis] || 0
    @cha = options[:cha] || 0
    @feats = options[:feats] || []
    @weapons = options[:weapons]
    @death_saves = []
    set_proficiency_bonus
    set_starting_hp
    equip_weapons
    train_feats
  end

  def take_turn
    return roll_death_save if dying
    super unless stable
  end

  def heal healing
    super healing
    self.dying = false
    self.stable = false
    self.death_saves = []
  end

  def pc?
    true
  end

  def spellcaster?
    false
  end

  def equip_offhand_weapon weapon
    character.bonus_actions << weapon
    ability_bonus = send weapon.ability
    weapon.attack_bonus = ability_bonus + proficiency_bonus
    weapon.damage_bonus = 0
    weapon.character = self
  end

  def before_short_rest
    take_turn until !dying
    take_turn while valid_action? && standing?
    actions.each(&:after_encounter)
    self.helper = nil
  end

  def short_rest
    roll_hit_die until hit_dice.empty? || current_hp == hp
  end

  def renew
    self.class.new(options)
  end

  def sheath_weapons
    bonus_actions.select(&:weapon?).reject!(&:light)
    self.melee = false if ranged
  end

  def inspect
    "#<#{self.class} hp=#{current_hp} hit_dice=[#{hit_dice_string}]#{" death_saves=#{death_saves}" unless standing?}#{' dead' if dead}#{' dying' if dying}#{' stable' if stable}>"
  end

  def hit_dice_string
    hit_dice.map { |hd| 'd' + hd.type.to_s}.join(', ')
  end

  def hit_dice_average
    hit_dice.map(&:average).sum + hit_dice.count * con
  end

  private

  def train_feats
    feats.each do |feat|
      case feat
      when :great_weapon_master then train_great_weapon_master
      when :heavy_armor_master then self.extend HeavyArmorMaster
      when :crossbow_expert then train_crossbow_expert
      when :healer then self.actions << Healer.new
      end
    end
  end

  def train_crossbow_expert
    hand_crossbow = actions.find { |action| action.name == 'hand crossbow' }
    return unless hand_crossbow
    hand_crossbow.extend CrossbowExpert
    bonus_attack = hand_crossbow.dup
    self.bonus_actions << bonus_attack.extend(CrossbowExpert)
  end

  def train_great_weapon_master
    great_weapons = actions.select(&:weapon?).select(&:great)
    great_weapons.each { |weapon| weapon.extend GreatWeaponMaster }
    cleave = great_weapons.map do |weapon|
      action = Weapon.new weapon.weapon
      action.extend GreatWeaponMaster
      action.attack_bonus = str + proficiency_bonus
      action.damage_bonus = str
      action.character = self
      action
    end
    self.bonus_actions += cleave
  end

  def valid_action?
    (actions+bonus_actions).map(&:evaluate).any? { |value| value > 0 }
  end

  def check_if_dying
    return if current_hp > 0
    disengage
    if hp + current_hp > 0
      self.dying = true
      self.current_hp = 0
      p "#{name} is dying."
    else
      p "#{name} took massive damage! "
      die
    end
  end

  def die
    super
    self.dying = false
    self.stable = false
  end

  def roll_death_save
    print "\nIt's #{name}'s turn.\n"
    roll = D20.roll
    case roll
    when 1
      p "#{name} critically fails a death save!"
      self.death_saves += [false, false]
    when 2..9
      p "#{name} fails a death save."
      self.death_saves << false
    when 10..19
      p "#{name} succeeds a death save."
      self.death_saves << true
    when 20
      p "#{name} critically succeeds a death save! #{name} is back in the fight."
      heal 1
      take_turn
    end
    if death_saves.count(true) > 2
      self.dying = false
      self.stable = true
      p "#{name} is stable."
    end
    die if death_saves.count(false) > 2
    p "death saves: #{death_saves}" unless standing?
  end

  def set_starting_hp
    @hp = hd_type + (hd_type / 2 + 1) * (level - 1) + con * level
    @current_hp = hp
    @hit_dice = Array.new(level) { Dice.new "1d#{hd_type}" }
  end

  def hd_type
    self.class::HD_Type
  end

  def roll_hit_die
    healing = hit_dice.pop.roll + con
    p "#{name} rolls a hit die."
    heal healing
  end
end
