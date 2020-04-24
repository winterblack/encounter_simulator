require_relative 'character'

class PlayerCharacter < Character
  attr_accessor :dying, :death_saves, :stable, :hit_dice
  attr_reader :options, :ranged

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
    @weapons = options[:weapons]
    @death_saves = []
    set_proficiency_bonus
    set_starting_hp
    equip_weapons
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

  def familiar?
    false
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
    until (actions+bonus_actions).map(&:evaluate).none? { |value| value > 0 }
      take_turn
    end
  end

  def short_rest
    roll_hit_die until hit_dice.empty? || current_hp == hp
  end

  def renew
    self.class.new(options)
  end

  def sheath_weapons
    bonus_actions.reject!(&:weapon?)
    self.melee = false if ranged
  end

  def inspect
    "#<#{self.class} hp=#{current_hp} hit_dice=#{hit_dice.map &:type}#{" death_saves=#{death_saves}" unless standing?}#{' dead' if dead}#{' dying' if dying}#{' stable' if stable}>"
  end

  private

  def check_if_dying
    return if current_hp > 1
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
    roll = D20.roll
    case roll
    when 1
      self.death_saves += [false, false]
      p "#{name} critically failed a death save!"
    when 2..9
      self.death_saves << false
      p "#{name} failed a death save."
    when 10..19
      self.death_saves << true
      p "#{name} succeeded a death save."
    when 20
      heal 1
      p "#{name} critically succeeded a death save! #{name} is back in the fight."
      take_turn
    end
    if death_saves.count(true) > 2
      self.dying = false
      self.stable = true
      p "#{name} is stable."
    end
    die if death_saves.count(false) > 2
    p "death saves: #{death_saves}"
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
