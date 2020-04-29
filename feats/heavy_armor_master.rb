module HeavyArmorMaster
  def take damage
    reduced_damage = [damage - 3, 0].max
    self.current_hp -= reduced_damage
    p "#{name} takes #{reduced_damage} damage. #{name} is at #{current_hp} hp."
    check_if_dying
  end
end
