require_relative 'character'
require_relative 'attack'

Fighter = Character.new({
  hp: 13,
  ac: 16,
  initiative: 0,
  actions: [Attack.new(+5, '2d6+3')],
  })

Archer = Character.new({
  hp: 10,
  ac: 15,
  initiative: 3,
  actions: [Attack.new(+7, '1d8+3')]
  })
