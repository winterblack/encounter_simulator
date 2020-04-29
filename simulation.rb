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
  elsif args.include?('hard')
    Simulation.new(count: 1000).run_hard_encounters
  elsif args.include?('medium')
    Simulation.new(count: 1000).run_medium_encounters
  elsif args.include?('monsters')
    Simulation.new.run_monster_combinations
  elsif args.include?('monster-balance')
    Simulation.new(count: 1000).run_monster_balance
  elsif args.include?('balanced')
    Simulation.new.run_balanced
  elsif args.include?('custom')
    Simulation.new(count: 1).run_custom
  elsif args.include?('spells')
    Simulation.new(count: 1000).run_spell_test
  elsif args.include?('feats')
    Simulation.new(count: 10000).run_feat_test
  elsif args.include?('encounter')
    Simulation.new.run_encounter
  else
    Simulation.new(count: 10000).run
  end
end

class Simulation
  attr_reader :scenerio, :count, :party, :trials

  def initialize options={}
    @scenerio = options[:scenerio] || standard_scenerio
    @count = options[:count] || 100
    @party = options[:party] || standard_party
    @trials = []
  end

  def run_encounter
    encounter = Encounter.new(Array.new(2) { Monster.new('Ogre') })
    Trial.new(encounter, 1).run party
  end

  def run_spell_test
    deltas = {}
    @fighter_feats = []
    @cleric_spells = [:healing_word]
    @wizard_spells = [:mage_armor, :sleep]
    control = Trial.new(scenerio, count).run([cleric, fighter, rogue, wizard])
    spells.each do |spell|
      next if [:healing_word, :sleep].include? spell
      @cleric_spells = [:healing_word, spell]
      @wizard_spells = [:sleep, :mage_armor, spell]
      trials << trial = Trial.new(scenerio, count).run([cleric, fighter, rogue, wizard])
      trial.name = spell
      deltas[spell] = {
        tpk: (control.tpk_chance - trial.tpk_chance),
        zero_death: (trial.death_chance(0) - control.death_chance(0))
      }
    end
    puts
    p 'control'
    control.outcome
    trials.each do |trial|
      puts
      p trial.name
      trial.outcome
      p "TPK chance - %#{(deltas[trial.name][:tpk] * 100).round(3)}"
      p "Zero death chance + %#{(deltas[trial.name][:zero_death] * 100).round(3)}"
    end
  end

  def run_feat_test
    deltas = {}
    @cleric_feats = []
    @fighter_feats = []
    @rogue_feats = []
    @wizard_feats = []
    @rogue_weapons = ['light crossbow', 'shortsword']
    without_feats = Trial.new(scenerio, count).run([cleric, fighter, rogue, wizard])
    with_feats = Trial.new(scenerio, count).run(party)
    print "\n Without Feats \n"
    without_feats.outcome
    print "\n With Feats \n"
    with_feats.outcome
    print "\n Delats \n"
    p "TPK chance - %#{(without_feats.tpk_chance - with_feats.tpk_chance) * 100}"
    p "Zero death chance + %#{(with_feats.death_chance(0) - without_feats.death_chance(0)) * 100}"
  end

  def run_balanced
    combined_trials = Trial.new(nil, 0)
    combined_trials.party = party
    balanced_adventures.each do |adventure|
      outcomes = Trial.new(adventure, count).run(party).outcomes
      combined_trials.outcomes += outcomes
    end
    combined_trials.outcome
  end

  def run
    Trial.new(scenerio, count).run(party).outcomes
  end

  def run_custom
    Trial.new(custom_scenerio, count).run(party).outcomes
  end

  def run_party_combinations
    party_combinations.each do |party|
      @trials << Trial.new(scenerio, count).run(party)
    end
    analyze_trials
  end

  def run_monster_combinations
    combined_trials = Trial.new(nil, 0)
    combined_trials.party = party
    encounter_combinations.each do |adventure|
      @trials << Trial.new(adventure, count).run(party)
    end
    analyze_trials
  end

  def run_hard_encounters
    combined_trials = Trial.new(nil, 0)
    combined_trials.party = party
    dmg_encounters(300).each do |encounter|
      adventure = AdventuringDay.new(Array.new(4) { encounter })
      trial = Trial.new(adventure, count).run(party)
      @trials << trial
      combined_trials.outcomes += trial.outcomes
    end
    trials.each(&:outcome)
    combined_trials.outcome
  end

  def run_medium_encounters
    combined_trials = Trial.new(nil, 0)
    combined_trials.party = party
    dmg_encounters(200).each do |encounter|
      adventure = AdventuringDay.new(Array.new(6) { encounter })
      trial = Trial.new(adventure, count).run(party)
      @trials << trial
      combined_trials.outcomes += trial.outcomes
    end
    trials.each(&:outcome)
    combined_trials.outcome
  end


  def run_monster_balance
    %w(Kobold Goblin Orc Bugbear Ogre).each do |monster|
      no_death_chance = 1
      n = 1
      trials = []
      until no_death_chance < 0.9
        monsters = Array.new(n) { Monster.new(monster) }
        encounters = Array.new(4) { Encounter.new(monsters) }
        adventure = AdventuringDay.new(encounters)
        trials << Trial.new(adventure, count).run(party)
        no_death_chance = trials.last.death_chance(0)
        n += 1
      end
      @trials << trials.min do |a, b|
        (a.death_chance(0) - 0.9).abs <=> (b.death_chance(0) - 0.9).abs
      end
    end
    trials.each(&:outcome)
  end

  private

  def spells
    [
      :bless,
      :burning_hands,
      :cure_wounds,
      :find_familiar,
      :guiding_bolt,
      :healing_word,
      :mage_armor,
      :magic_missile,
      :shield,
      :shield_of_faith,
      :sleep,
    ]
  end

  def cleric_spells
    @cleric_spells ||= [:healing_word]
  end

  def wizard_spells
    @wizard_spells ||= [:burning_hands, :find_familiar, :sleep, :magic_missile, :shield]
  end

  def cleric_feats
    @cleric_feats ||= [:heavy_armor_master]
  end

  def fighter_feats
    @fighter_feats ||= [:great_weapon_master]
  end

  def rogue_feats
    @rogue_feats ||= [:crossbow_expert]
  end

  def wizard_feats
    @wizard_feats ||= [:healer]
  end

  def rogue_weapons
    @rogue_weapons ||= ['hand crossbow']
  end

  def feats
    [:great_weapon_master]
  end

  def balanced_adventures
    balanced_encounters.repeated_combination(2).map do |encounters|
      AdventuringDay.new(encounters)
    end
  end

  def balanced_encounters
    [
      Encounter.new( Array.new(5) { Monster.new('Kobold') }),
      Encounter.new(Array.new(4) { Monster.new('Goblin') }),
      Encounter.new(Array.new(3) { Monster.new('Orc') }),
      Encounter.new(Array.new(1) { Monster.new('Bugbear') }),
    ]
  end

  def dmg_encounters target
    find_encounters(target).map do |xps|
      Encounter.new(xps.map { |xp| monster_by_xp xp })
    end
  end

  def find_encounters target, i=0, sum=0, multiplier=1, encounter=[]
    return [encounter] if sum * multiplier == target
    return [] if sum * multiplier > target || i == xps.length
    count = encounter.length
    result = find_encounters(target, i+1, sum, multiplier, encounter)
    max = (target - sum) / xps[i]
    _encounter = encounter
    j = 1
    while j <= max
      _encounter = _encounter.dup << xps[i]
      sum = sum + xps[i]
      multiplier = get_multiplier(count + 1)
      count += 1
      result = result.concat(find_encounters(target, i+1, sum, multiplier, _encounter))
      j += 1
    end
    result
  end

  def xps
    [25, 50, 100, 200, 450, 700, 1100, 1800, 2300, 2900, 3900, 5000]
  end

  def encounter_combinations
    hard_encounters.repeated_combination(4).map do |adventure|
      AdventuringDay.new(adventure)
    end
  end

  def monster_by_xp xp
    case xp
    when 25 then Monster.new('Kobold')
    when 50 then Monster.new('Goblin')
    when 100 then Monster.new('Orc')
    when 200 then Monster.new('Bugbear')
    when 450 then Monster.new('Ogre')
    end
  end

  def get_multiplier count
    case count
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

  def standard_scenerio
    AdventuringDay.new([
      Encounter.new(Array.new(6) { Monster.new('Kobold') }),
      Encounter.new(Array.new(3) { Monster.new('Goblin') }),
      Encounter.new(Array.new(2) { Monster.new('Orc') }),
      Encounter.new(Array.new(1) { Monster.new('Ogre') }),
    ])
  end

  def custom_scenerio
    AdventuringDay.new([
      Encounter.new(Array.new(6) { Monster.new('Kobold') }),
      Encounter.new(Array.new(3) { Monster.new('Goblin') }),
      Encounter.new(Array.new(2) { Monster.new('Orc') }),
      # Encounter.new(Array.new(1) { Monster.new('Ogre') }),
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
      spells: cleric_spells,
      domain: :life,
      feats: cleric_feats,
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
      fighting_styles: [:great_weapon_fighting],
      feats: fighter_feats,
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
      weapons: rogue_weapons,
      feats: rogue_feats,
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
      spells: wizard_spells,
      feats: wizard_feats,
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
