require_relative 'encounter'
require_relative 'character'
require_relative 'attack'

greatsword = Attack.new('Greatsword', +5, '2d6+3')
crossbow = Attack.new('Light Crossbow', +5, '1d8+3')
mace = Attack.new('Mace', +5, '1d6+3')
greataxe = Attack.new('Greataxe', +5, '1d12+3')

fighter = Character.new(
  pc: true,
  name: 'Fighter',
  initiative: 2,
  actions: [greatsword],
  ac: 16,
  hp: 13,
  melee: true,
)

rogue = Character.new(
  pc: true,
  name: 'Rogue',
  initiative: 3,
  actions: [crossbow],
  ac: 14,
  hp: 11,
)

wizard = Character.new(
  pc: true,
  name: 'Wizard',
  initiative: 3,
  actions: [crossbow],
  ac: 13,
  hp: 8,
)

cleric = Character.new(
  pc: true,
  name: 'Cleric',
  initiative: 0,
  actions: [mace],
  ac: 18,
  hp: 11,
  melee: true,
)

party = [fighter, rogue, wizard, cleric]

orcs = []
4.times do |i|
  orcs << Character.new(
    name: "Orc #{i+1}", initiative: 1,
    actions: [greataxe],
    ac: 13,
    hp: 15,
    melee: true,
  )
end

Encounter.new(party + orcs).run

party.each { |character| p character }
orcs.each { |orc| p orc }
