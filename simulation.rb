require 'require_all'
require_all 'characters/classes'
require_relative 'characters/monsters'
require_relative 'actions/weapons'
require_all 'actions/spells'
require_relative 'encounter'
require_relative 'trial'

fighter = Fighter.new(
  name: 'Fighter',
  level: 1,
  str: +3,
  dex: +2,
  con: +3,
  ac: 16, #chain mail
  actions: [Weapon.forge(:greatsword)],
)

rogue = Rogue.new(
  name: 'Rogue',
  level: 1,
  dex: +3,
  con: +3,
  int: +2,
  ac: 14, #leather
  actions: [Weapon.forge(:light_crossbow)]
)

wizard = Wizard.new(
  name: 'Wizard',
  level: 1,
  dex: +3,
  con: +2,
  int: +3,
  ac: 13, #unarmored
  actions: [
    Weapon.forge(:light_crossbow),
    BurningHands.new,
  ],
)

cleric = Cleric.new(
  name: 'Cleric',
  level: 1,
  str: +2,
  con: +3,
  wis: +3,
  ac: 18, #chain mail, shield
  actions: [Weapon.forge(:mace)],
  bonus_actions: [HealingWord.new]
)

party = [fighter, rogue, wizard, cleric]

orcs = []

4.times { |i| orcs << Orc.new(name: "Orc #{i+1}") }

characters = party + orcs

trial = Trial.new(characters, 1000).run
