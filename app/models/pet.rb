class Pet < ApplicationRecord
  
  STAGES = {
    0 => { name: "egg",   sprite: "🥚", ticks_to_evolve: 20  },
    1 => { name: "baby",  sprite: "🐣", ticks_to_evolve: 120 },
    2 => { name: "child", sprite: "🐥", ticks_to_evolve: 360 },
    3 => { name: "teen",  sprite: "🐤", ticks_to_evolve: 720 }, 
    4 => { name: "adult", sprite: "🦆", ticks_to_evolve: 1440 }, # 24 hrs
    5 => { name: "elder", sprite: "🦉", ticks_to_evolve: nil  },
    6 => { name: "dead",  sprite: "💀", ticks_to_evolve: nil  },
  }.freeze()

  POOP_EVERY = 30 # gross, yes i know
  validates :name, presence: true, length: { maximum: 20 }
  validates :stage, inclusion: { in: 0..6 }
  validates :hunger, numericality: { in: 0..100 }
  validates :happiness, numericality: { in: 0..100 }
  validates :energy, numericality: { in: 0..100 }
  validates :hygiene, numericality: { in: 0..100 }
  validates :health, numericality: { in: 0..100 }
  def stage_info = STAGES[stage]
  def stage_name = stage_info[:name]
  def sprite = stage_info[:sprite]
  def alive? = stage < 6
  def dead? = stage == 6
  def egg? = stage == 0
  def hatched? = stage >= 1
  def mood
    case happiness
    when 80..100 then "amazing!!"
    when 60..79 then "good!"
    when 40..59 then "okay.."
    when 20..39 then "bad!"
    else "awful!!"
    end
  end

  # actions
  
  def feed!(food_type = :normal)
    return { ok: false, msg: "#{name} can't eat yet — still in the egg! :c" } if egg?
    return { ok: false, msg: "#{name} is sleeping... shhh :3" } if sleeping?
    return { ok: false, msg: "#{name} is gone, ya can't feed her anymore :c" } if dead?

    nutrition, weight_gain, happiness_gain = case food_type.to_sym
      when :meal then [40, 8, 10]
      when :snack then [20, 4, 20]
      when :veggie then [35, 2, 5]
      else [30, 5, 15]
    end
    
    self.hunger = clamp(hunger - nutrition, 0, 100)
    self.weight = clamp(weight + weight_gain, 0, 100)
    self.happiness = clamp(happiness + happiness_gain, 0, 100)
    save! # why does this have an exclamation mark its so goofy i love ruby
    { ok: true, msg: "#{name} ate happily!!!! :3" }
  end
  
  def play!
    return { ok: false, msg: "#{name} is still in the egg! :c" } if egg?
    return { ok: false, msg: "#{name} is too sleepy to play :c" } if sleeping?
    return { ok: false, msg: "#{name} is gone :c" } if dead?
    return { ok: false, msg: "#{name} is too hungry to play! feed them :c" } if hunger >= 80
    self.happiness = clamp(happiness + 25, 0, 100)
    self.energy = clamp(energy - 20, 0, 100)
    self.hunger = clamp(hunger + 10, 0, 100)
    self.weight = clamp(weight - 3, 0, 100)
    save!
    { ok: true, msg: "#{name} played and and lost some weight :)" }
  end

  def sleep_action!
    return { ok: false, msg: "#{name} is still in the egg! :c" } if egg?
    return { ok: false, msg: "#{name} is gone :c" } if dead?
    if sleeping?
      self.sleeping = false
      self.energy = clamp(energy + 40, 0, 100)
      self.happiness = clamp(happiness + 10, 0, 100)
      msg = "#{name} woke up feeling refreshed!!"
    else
      self.sleeping = true
      msg = "#{name} is drifting offf..."
    end
    save!
    { ok: true, msg: msg }
  end

  def clean!
    return { ok: false, msg: "#{name} is still in the egg! :c" } if egg?
    return { ok: false, msg: "#{name} is gone :c" } if dead?

    self.hygiene = clamp(hygiene + 40, 0, 100)
    self.happiness = clamp(happiness - 20, 0, 100) if poop_on_screen? # yes im removing happiness cats hate showers >:3
    self.poop_on_screen = false
    save!
    { ok: true, msg: "#{name} is squeaky clean! they kinda hated it tho :(()" }
  end

  def discipline!
    return { ok: false, msg: "#{name} is still in the egg! :c" } if egg?
    return { ok: false, msg: "#{name} is gone :c" } if dead?

    self.discipline = clamp(self.discipline + 15, 0, 100)
    self.happiness = clamp(happiness - 10, 0, 100)
    save!
    { ok: true, msg: "#{name} got some tough love :/" }
  end

  def medicine!
    return { ok: false, msg: "#{name} is gone :c" } if dead?
    return { ok: false, msg: "#{name} isn't sick!!!" } unless sick?
    self.sick = false
    self.health = clamp(health + 30, 0, 100)
    self.happiness = clamp(happiness - 10, 0, 100)
    save!
    { ok: true, msg: "#{name} took their medicine and is feeling better, although they retched a bit :(" }
  end

  def tick!
    return if dead?
    elapsed = calculate_elapsed_ticks
    return if elapsed < 1 # this prevents pet from overaging
    elapsed.times { apply_single_tick }
    self.last_tick_at = Time.current
    save!
  end

  def check_death!
    return if dead?
    cause = nil
    cause = "starvation" if hunger >= 100
    cause = "exhaustion" if energy <= 0 && !sleeping?
    cause = "illness" if health <= 0
    if cause
      self.stage = 6
      self.death_cause = cause
      save!
    end  
  end

  private
  def clamp(val, min, max) = [[val, min].max, max].min

  def calculate_elapsed_ticks
    return 1 unless last_tick_at
    (Time.current - last_tick_at).to_i / 60
  end

  def apply_single_tick
    self.age_ticks += 1
    
    unless sleeping?
      self.hunger = clamp(hunger + 2, 0, 100)
      self.happiness = clamp(happiness - 1, 0, 100)
      self.energy = clamp(energy - 1, 0, 100)
      self.hygiene = clamp(hygiene - 1, 0, 100)
    else
      self.hunger = clamp(hunger + 1, 0, 100)
      self.energy = clamp(energy + 2, 0, 100)
    end

    # chance to get sick at random b.o. health
    if !sick? && rand < sickness_probability
      self.sick = true
      self.health = clamp(health - 10, 0, 100)
    end

    self.health = clamp(health - 3, 0, 100) if sick?

    if hatched? && age_ticks % POOP_EVERY == 0
      self.poop_on_screen = true
      self.hygiene = clamp(hygiene - 20, 0, 100)
    end
  end

    def sickness_probability
      base = 0.002
      base += 0.01 if hunger > 70

      base += 0.01 if hygiene < 30

      base += 0.01 if happiness < 20
      base
    end

    def should_evolve?
      evo = STAGES[stage][:ticks_to_evolve]
      return false if evo.nil? || stage >= 5
      age_ticks >= evo
    end

    def evolve!
      self.stage += 1
      self.age_ticks = 0
      self.health = clamp(health + 10, 0, 100)
    end
end