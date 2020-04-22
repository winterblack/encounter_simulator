module PlayerCharacter
  attr_accessor :dying, :death_saves, :stable, :hit_dice
  attr_reader :spell_slots
  def initialize options
    super options
    @pc = true
    @death_saves = []
    set_proficiency_bonus
    set_starting_hp
    equip_weapons
  end

  def take_turn
    return roll_death_save if dying
    super
  end

  def short_rest
    return unless current_hp > 0
    roll_hit_die until hit_dice.empty? || current_hp == hp
  end

  def take damage
    super damage
    check_if_dying
  end

  def heal healing
    super healing
    self.dying = false
    self.stable = false
    self.death_saves = []
  end

  def standing
    !dead && !dying && !stable
  end

  def inspect
    "<#{name} hp=#{current_hp}#{" spell_slots=#{spell_slots_remaining[1..-1]}" if spell_slots}#{" death_saves=#{death_saves}" if !standing}#{' dead' if dead}#{' dying' if dying}#{' stable' if stable}>"
  end

  private

  def roll_hit_die
    heal(hit_dice.pop.roll + con)
  end

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
    false
  end

  def set_starting_hp
    hd_type = self.class::HD_Type
    @hp = hd_type + (hd_type / 2 + 1) * (level - 1) + con * level
    @current_hp = hp
    @hit_dice = Array.new(level) { Dice.new "1d#{hd_type}" }
  end
end
