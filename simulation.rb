require 'require_all'
require_all 'characters/classes'
require_relative 'characters/monster'
require_relative 'encounter'
require_relative 'adventuring_day'
require_relative 'trial'

fighter = Fighter.new(
  name: 'Tordek',
  level: 1,
  str: +3,
  dex: +2,
  con: +3,
  ac: 16, #chain mail
  weapons: ['greatsword'],
  fighting_styles: [:great_weapon_fighting]
)

rogue = Rogue.new(
  name: 'Lidda',
  level: 1,
  dex: +3,
  con: +3,
  int: +2,
  ac: 14, #leather
  weapons: ['light crossbow', 'shortsword']
)

wizard = Wizard.new(
  name: 'Mialee',
  level: 1,
  dex: +3,
  con: +2,
  int: +3,
  ac: 13, #unarmored
  weapons: ['light crossbow', 'dagger'],
  spells: [:burning_hands]
)

cleric = Cleric.new(
  name: 'Jozan',
  level: 1,
  str: +2,
  con: +3,
  wis: +3,
  ac: 18, #chain mail, shield
  weapons: ['mace'],
  spells: [:healing_word, :cure_wounds],
  domain: :life
)

party = [fighter, rogue, wizard, cleric]

encounters = []
encounters << Encounter.new(Array.new(3) { Monster.new 'Goblin' })
encounters << Encounter.new(Array.new(3) { Monster.new 'Goblin' })
encounters << Encounter.new(Array.new(3) { Monster.new 'Goblin' })
encounters << Encounter.new(Array.new(3) { Monster.new 'Goblin' })

day = AdventuringDay.new(encounters)

Trial.new(day, 100000/encounters.count).run(party)
