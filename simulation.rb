require 'pry'
require 'require_all'
require_all 'characters/classes'
require_relative 'characters/monster'
require_relative 'encounter'
require_relative 'adventuring_day'
require_relative 'trial'

def run_simulation args
  if args.include?('parties')
    Simulation.new.run_party_combinations
  elsif args.include?('monsters')
    Simulation.new.run_monster_combinations
  else
    Simulation.new.run
  end
end

class Simulation
  attr_reader :scenerio, :count, :party, :trials

  def initialize options={}
    @scenerio = options[:scenerio] || standard_scenerio
    @count = options[:count] || 45360
    @party = options[:party] || standard_party
    @trials = []
  end

  def run
    Trial.new(scenerio, count/4).run party
  end

  def run_party_combinations
    @count = party_combination_count
    party_combinations.each do |party|
      self.trials << Trial.new(scenerio, count).run(party)
    end
    analyze_trials
  end

  def run_monster_combinations
    combined_trials = Trial.new(nil, count)
    combined_trials.party = party
    @count = encounter_combination_count
    encounter_combinations.each do |encounter|
      self.trials << Trial.new(encounter, count).run(party)
    end
    analyze_trials
  end

  private

  def encounter_combination_count
    count / encounter_combinations.count / 4
  end

  def encounter_combinations
    @encounters ||= (1..6).flat_map do |n|
      challenge_ratings.repeated_combination(n).to_a
    end.select do |encounter|
      adjusted_xp(encounter) == 300
    end.map do |encounter|
      Encounter.new(encounter.map { |cr| monster_by_cr cr })
    end.repeated_combination(4).map do |adventure|
      AdventuringDay.new(adventure)
    end
  end

  def adjusted_xp encounter
    encounter.map { |cr| cr_xp[cr] }.reduce(0, :+) * multiplier(encounter.count)
  end

  def challenge_ratings
    ['1/8', '1/4', '1/2', 1]
  end

  def cr_xp
    {
      '1/8' => 25,
      '1/4' => 50,
      '1/2' => 100,
      1 => 200,
      2 => 450,
    }
  end

  def monster_by_cr cr
    case cr
    when '1/8' then Monster.new('Kobold')
    when '1/4' then Monster.new('Goblin')
    when '1/2' then Monster.new('Orc')
    end
  end

  def multiplier count
    case count
    when 0 then 0
    when 1 then 1
    when 2 then 1.5
    when 3..6 then 2
    when 7..10 then 2.5
    else 3
    end
  end

  def party_combinations
    @party_combinations ||= party.repeated_combination(4)
  end

  def party_combination_count
    (count / party_combinations.count / scenerio.count) || 1
  end

  def standard_scenerio
    AdventuringDay.new([
      Encounter.new( Array.new(4) { Monster.new('Kobold') }),
      Encounter.new(Array.new(3) { Monster.new('Goblin') }),
      Encounter.new(Array.new(3) { Monster.new('Goblin') }),
      Encounter.new(Array.new(2) { Monster.new('Orc') }),
    ])
  end

  def standard_party
    [cleric, fighter, rogue, wizard]
  end

  def cleric
    Cleric.new(
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
  end

  def fighter
    Fighter.new(
      name: 'Tordek',
      level: 1,
      str: +3,
      dex: +2,
      con: +3,
      ac: 16, #chain mail
      weapons: ['greatsword'],
      fighting_styles: [:great_weapon_fighting]
    )
  end

  def rogue
    Rogue.new(
      name: 'Lidda',
      level: 1,
      dex: +3,
      con: +3,
      int: +2,
      ac: 14, #leather
      weapons: ['light crossbow', 'shortsword']
    )
  end

  def wizard
    Wizard.new(
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
  end

  def analyze_trials
    control = Trial.new(standard_scenerio, count).run(party)
    no_death_trial = trials.max { |a, b| a.death_chance(0) <=> b.death_chance(0) }
    no_tpk_trial = trials.min { |a, b| a.tpk_chance <=> b.tpk_chance }
    someone_dies_trial = trials.min { |a, b| a.death_chance(0) <=> b.death_chance(0) }
    everyone_dies_trial = trials.max { |a, b| a.tpk_chance <=> b.tpk_chance }

    print "Control"
    control.outcome
    print "No one dies trial"
    no_death_trial.outcome
    print "No TPK trial"
    no_tpk_trial.outcome
    print "Someone dies trial"
    someone_dies_trial.outcome
    print "Everyone dies trial"
    everyone_dies_trial.outcome
  end
end

run_simulation ARGV if __FILE__ == $PROGRAM_NAME
