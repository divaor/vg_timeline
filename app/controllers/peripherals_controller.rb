class PeripheralsController < ApplicationController

  def index
    @peripherals = Peripheral.where("LOWER(name) LIKE ?", "%#{params[:search].downcase}%")
    respond_to do |format|
      format.js
    end
  end
end
