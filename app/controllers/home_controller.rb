class HomeController < ApplicationController
  def index
    redirect_to pet_path(@current_pet) if @current_pet&.alive?
  end
end