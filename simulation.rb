require 'require_all'
require_all 'characters/classes'
require_relative 'characters/monsters'
require_relative 'encounter'
require_relative 'trial'

fighter = Fighter.new(
  name: 'Tordek',
  level: 1,
  str: +3,
  dex: +2,
  con: +3,
  ac: 16, #chain mail
  weapons: [:greatsword],
  fighting_styles: [:great_weapon_fighting]
)

rogue = Rogue.new(
  name: 'Lidda',
  level: 1,
  dex: +3,
  con: +3,
  int: +2,
  ac: 14, #leather
  weapons: [:light_crossbow, :shortsword]
)

wizard = Wizard.new(
  name: 'Mialee',
  level: 1,
  dex: +3,
  con: +2,
  int: +3,
  ac: 13, #unarmored
  weapons: [:light_crossbow],
  spells: [:burning_hands, :shocking_grasp]
)

cleric = Cleric.new(
  name: 'Jozan',
  level: 1,
  str: +2,
  con: +3,
  wis: +3,
  ac: 18, #chain mail, shield
  weapons: [:mace],
  spells: [:healing_word],
)

party = [fighter, rogue, wizard, cleric]

orcs = ['Blackhand', 'Orgrim', 'Grommash', 'Aggralan']
orcs.map! { |name| Orc.new(name: name) }

characters = party + orcs

trial = Trial.new(characters, 100).run
