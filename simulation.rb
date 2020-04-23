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
  spells: [:burning_hands, :find_familiar]
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

# def create_adventure monster
#   n = 1
#   no_death_chance = 1.0
#   trials = []
#   until no_death_chance < 0.75
#     monsters = Array.new(n) { Monster.new(monster) }
#     encounters = Array.new(2) { Encounter.new(monsters) }
#     adventure = AdventuringDay.new(encounters)
#     trials << Trial.new(adventure, 10000).run(Party)
#     no_death_chance = trials.last.death_chance(0)
#     n += 1
#   end
#   trials.min { |a, b| (a.death_chance(0) - 0.75).abs <=> (b.death_chance(0) - 0.75).abs }
# end
#
# trials = []

# %w(Kobold Goblin Orc Bugbear Ogre).each do |monster|
#   trials << create_adventure(monster)
# end

# trials.each do |trial|
#   trial.outcome
# end

Party = [cleric, fighter, rogue, wizard]

encounters = []
encounters << Encounter.new(Array.new(1) { Monster.new('Ogre') })
# encounters << Encounter.new(Array.new(5) { Monster.new('Kobold') })
encounters << Encounter.new(Array.new(3) { Monster.new('Goblin') })
# encounters << Encounter.new(Array.new(3) { Monster.new('Orc') })
# encounters << Encounter.new(Array.new(2) { Monster.new('Bugbear') })

adventure = AdventuringDay.new(encounters)

Trial.new(adventure, 10000).run Party

# trials = []
#
# Party.repeated_combination(4).each do |party|
#   trials << Trial.new(adventure, 100000/36/encounters.count).run(party)
# end

with_familiar = Trial.new(adventure, 10000).run(Party)

Party.find { |pc| pc.class == Wizard }.spells.delete(:find_familiar)

without_familiar = Trial.new(adventure, 10000).run(Party)

print "Comparison"

without_familiar.outcome
with_familiar.outcome

print "Change in no death chance:"
puts "#{(with_familiar.death_chance(0) - without_familiar.death_chance(0)) * 100}%"

print "Change in TPK chance:"
puts "#{(with_familiar.tpk_chance - without_familiar.tpk_chance) * 100}%"

# encounters.repeated_permutation(2).each do |enc|
#   adv = AdventuringDay.new(enc)
#   trials << Trial.new(adv, 100000/16/2).run(Party)
# end

# control = Trial.new(adventure, 100000/36/encounters.count).run(Party)
#
# no_death_trial = trials.max { |a, b| a.death_chance(0) <=> b.death_chance(0) }
# # no_tpk_trial = trials.min { |a, b| a.tpk_chance <=> b.tpk_chance }
# someone_dies_trial = trials.min { |a, b| a.death_chance(0) <=> b.death_chance(0) }
# # everyone_dies_trial = trials.max { |a, b| a.tpk_chance <=> b.tpk_chance }
#
# print "Control"
# control.outcome
#
# print "No one dies trial"
# no_death_trial.outcome
# # print "No TPK trial"
# # no_tpk_trial.outcome
# print "Someone dies trial"
# someone_dies_trial.outcome
# print "Everyone dies trial"
# everyone_dies_trial.ouztcome
