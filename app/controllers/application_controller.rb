class ApplicationController < ActionController::Base
  before_action :set_current_pet

  private

  def set_current_pet
    @current_pet = Pet.find_by(id: session[:pet_id])
  end

end
