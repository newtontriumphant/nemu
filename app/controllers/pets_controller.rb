class PetsController < ApplicationController
  
  def new
    @pet = Pet.new
  end

  def create
    @pet = Pet.new(pet_params)
    @pet.last_tick_at = Time.current
    if @pet.save
      session[:pet_id] = @pet.id
      redirect_to pet_path(@pet), notice: "#{@pet.name} is hatching... it's a egg still!!!!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @pet = find_and_tick
    redirect_to root_path unless @pet
  end

  # following part is ai-gen simply due to repetition

  def feed
    @pet    = find_and_tick
    result  = @pet.feed!(params[:food_type] || :normal)
    render json: pet_json(@pet).merge(result)
  end

  def play
    @pet    = find_and_tick
    result  = @pet.play!
    render json: pet_json(@pet).merge(result)
  end

  def sleep_action
    @pet    = find_and_tick
    result  = @pet.sleep_action!
    render json: pet_json(@pet).merge(result)
  end

  def clean
    @pet    = find_and_tick
    result  = @pet.clean!
    render json: pet_json(@pet).merge(result)
  end

  def discipline
    @pet    = find_and_tick
    result  = @pet.discipline!
    render json: pet_json(@pet).merge(result)
  end

  def medicine
    @pet    = find_and_tick
    result  = @pet.medicine!
    render json: pet_json(@pet).merge(result)
  end

  def tick
    @pet = find_and_tick
    render json: pet_json(@pet).merge(ok: true, msg: nil)
  end

  # end

  private

  def pet_params
    params.require(:pet).permit(:name)
  end

  def find_and_tick
    pet = Pet.find_by(id: session[:pet_id])
    return nil unless pet
    pet.tick!
    pet.reload
    pet
  end

  def pet_json(pet) # save
    {
      id: pet.id, name: pet.name,
      stage: pet.stage, stage_name: pet.stage_name, sprite: pet.sprite,
      hunger: pet.hunger, happiness: pet.happiness,
      energy: pet.energy, hygiene: pet.hygiene,
      discipline: pet.discipline, health: pet.health, weight: pet.weight,
      age_ticks: pet.age_ticks, sleeping: pet.sleeping,
      sick: pet.sick, poop_on_screen: pet.poop_on_screen,
      mood: pet.mood, alive: pet.alive?, death_cause: pet.death_cause,
    }
  end
end