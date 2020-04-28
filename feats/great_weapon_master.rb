module GreatWeaponMaster
  attr_accessor :cleave

  def strike
    p "#{character.name} cleaves!" if bonus_action?
    super
    cleaving_weapons.each { |weapon| weapon.cleave = true } if cleave?
    self.cleave = false
  end

  def evaluate_target target
    return 0 if bonus_action? && !cleave
    super target
  end

  private

  def cleave?
    return false if bonus_action?
    crit || !target.standing?
  end

  def cleaving_weapons
    character.bonus_actions.select(&:weapon?).select(&:great)
  end
end
