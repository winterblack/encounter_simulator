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
  spells: [
    :burning_hands,
    :find_familiar,
  ]
)

cleric = Cleric.new(
  name: 'Jozan',
  level: 1,
  str: +2,
  con: +3,
  wis: +3,
  ac: 18, #chain mail, shield
  weapons: ['mace'],
  spells: [
    :healing_word,
    :cure_wounds,
    :guiding_bolt,
  ],
  domain: :life
)

Party = [cleric, fighter, rogue, wizard]

encounters = []
encounters << Encounter.new(Array.new(4) { Monster.new('Kobold') })
# encounters << Encounter.new(Array.new(3) { Monster.new('Goblin') })
encounters << Encounter.new(Array.new(2) { Monster.new('Orc') })
encounters << Encounter.new(Array.new(1) { Monster.new('Bugbear') })
# encounters << Encounter.new(Array.new(1) { Monster.new('Ogre') })

adventure = AdventuringDay.new(encounters)

# adventure.run(Party)

Trial.new(adventure, 10000).run Party
#
# trials = []
#
# Party.repeated_combination(4).each do |party|
#   trials << Trial.new(adventure, 10000/36/encounters.count).run(party)
# end
#
# control = Trial.new(adventure, 10000/36/encounters.count).run(Party)
#
# no_death_trial = trials.max { |a, b| a.death_chance(0) <=> b.death_chance(0) }
# no_tpk_trial = trials.min { |a, b| a.tpk_chance <=> b.tpk_chance }
# someone_dies_trial = trials.min { |a, b| a.death_chance(0) <=> b.death_chance(0) }
# everyone_dies_trial = trials.max { |a, b| a.tpk_chance <=> b.tpk_chance }
#
# print "Control"
# control.outcome
#
# print "No one dies trial"
# no_death_trial.outcome
# print "No TPK trial"
# no_tpk_trial.outcome
# print "Someone dies trial"
# someone_dies_trial.outcome
# print "Everyone dies trial"
# everyone_dies_trial.outcome
