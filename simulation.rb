require 'require_all'
require_all 'characters/classes'
require_relative 'characters/monster'
require_relative 'encounter'
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
  spells: [:healing_word],
  domain: :life
)

Party = [fighter, rogue, wizard, cleric]
orcs = Array.new(4).map { Monster.new 'Orc' }

def get_90 monster
  n = 1
  no_death_chance = 1.0
  trials = []
  until no_death_chance < 0.9
    monsters = Array.new(n).map { Monster.new monster }
    trials << Trial.new(Party + monsters, 1000).run
    no_death_chance = trials.last.no_death_chance
    n += 1
  end
  trials
end

kobolds = get_90 'Kobold'
goblins = get_90 'Goblin'
orcs = get_90 'Orc'
bugbears = get_90 'Bugbear'

kobolds[-2].print_results
goblins[-2].print_results
orcs[-2].print_results
bugbears[-2].print_results
