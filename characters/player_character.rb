module PlayerCharacter
  attr_accessor :dying, :death_saves, :stable
  def initialize options
    super options
    @pc = true
    @death_saves = []
    set_proficiency_bonus
    equip_weapons
    set_starting_hp
  end

  def take_turn
    return roll_death_save if dying
    super
  end

  def take damage
    super damage
    check_if_dying
  end

  def standing
    !dead && !dying && !stable
  end

  def inspect
    "<#{name} hp=#{current_hp}#{" death_saves=#{death_saves}" if !standing}#{' dead' if dead}#{' dying' if dying}#{' stable' if stable}>"
  end

  private

  def check_if_dying
    if current_hp < 1
      if hp + current_hp > 0
        self.dying = true
        self.current_hp = 0
        p "#{name} is dying."
      else
        die
      end
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
      self.death_saves = []
      self.dying = false
      self.current_hp = 1
      p "#{name} critically succeeded a death save!"
    end
    if death_saves.count(true) > 2
      self.dying = false
      self.stable = true
      p "#{name} is stable."
    end
    die if death_saves.count(false) > 2
    p "#{name}'s death saves: #{death_saves}" unless death_saves.empty?
  end

  def set_starting_hp
    hd_type = self.class::HD_Type
    @hp = hd_type + (hd_type / 2 + 1) * (level - 1) + con * level
    @current_hp = hp
  end

  def set_proficiency_bonus
    case level
    when 1..4
      @proficiency_bonus = 2
    when 5..8
      @proficiency_bonus = 3
    when 9..12
      @proficiency_bonus = 4
    when 13..16
      @proficiency_bonus = 5
    when 17..20
      @proficiency_bonus = 6
    end
  end
end
