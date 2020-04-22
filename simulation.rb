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

Party = [fighter, rogue, wizard, cleric]

encounters = Array.new(4) { Encounter.new(Array.new(2) { Monster.new('Orc')})}
day = AdventuringDay.new(encounters)

Trial.new(day, 10000).run(Party)
# trials = []
#
# parties = Party.repeated_combination(4).each do |party|
#   trials << Trial.new(day, 100000/35/4).run(party)
# end
#
# no_death_trial = trials.max { |a, b| a.death_chance(0) <=> b.death_chance(0) }
# no_tpk_trial = trials.min { |a, b| a.tpk_chance <=> b.tpk_chance }
# someone_dies_trial = trials.min { |a, b| a.death_chance(0) <=> b.death_chance(0) }
# everyone_dies_trial = trials.max { |a, b| a.tpk_chance <=> b.tpk_chance }
#
# print "No Death Trial"
# no_death_trial.outcome
# print "No TPK Trial"
# no_tpk_trial.outcome
# print "Someone Dies Trial"
# someone_dies_trial.outcome
# print "Everyone Dies Trial"
# everyone_dies_trial.outcome
