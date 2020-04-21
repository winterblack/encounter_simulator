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
  domain: :life
)

og_party = [fighter, rogue, wizard, cleric]

orcs = ['Blackhand', 'Orgrim', 'Grommash', 'Aggralan']
orcs.map! { |name| Orc.new(name: name) }

characters = og_party + orcs

Trial.new(characters, 100000).run
# trials = []
#
# parties = og_party.repeated_combination(4).each do |party|
#   new_party = party.map(&:renew)
#   new_orcs = orcs.map { |name| Orc.new(name: name) }
#   new_characters = new_party + new_orcs
#   trials << Trial.new(new_characters, 2857).run
# end
#
# trials.each &:calculate_averages
#
# no_death_trial = trials.max { |a, b| a.no_death_chance <=> b.no_death_chance }
# no_death_party = no_death_trial.characters.select(&:pc?).map &:class
# no_tpk_trial = trials.min { |a, b| a.tpk_chance <=> b.tpk_chance }
# no_tpk_party = no_tpk_trial.characters.select(&:pc?).map &:class
# someone_dies_trial = trials.min { |a, b| a.no_death_chance <=> b.no_death_chance }
# someone_dies_party = someone_dies_trial.characters.select(&:pc?).map &:class
# everyone_dies_trial = trials.max { |a, b| a.tpk_chance <=> b.tpk_chance }
# everyone_dies_party = everyone_dies_trial.characters.select(&:pc?).map &:class
#
# print "The party where no one died was #{no_death_party}\n"
# print "That party noe one died #{(no_death_trial.no_death_chance * 100).round(2)}% of the time.\n"
# print "The party with the fewest tpks was #{no_tpk_party}\n"
# print "That party everyone died #{(no_tpk_trial.tpk_chance * 100).round(2)}% of the time.\n"
# print "The party where someone died most was #{someone_dies_party}\n"
# print "That party no one died #{(someone_dies_trial.no_death_chance * 100).round(2)}% of the time.\n"
# print "The party with the most tpks was #{everyone_dies_party}\n"
# print "That party everyone died #{(everyone_dies_trial.tpk_chance * 100).round(2)}% of the time.\n"
