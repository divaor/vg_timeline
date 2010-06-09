class IndustryPeopleController < ApplicationController

  def index
    @industry_people = IndustryPerson.where("LOWER(name) LIKE ?", "%#{params[:search].downcase}%")
    respond_to do |format|
      format.js
    end
  end
end
