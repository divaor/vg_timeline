class ProjectLeader < ActiveRecord::Base
  belongs_to :game
  belongs_to :industry_person

  def industry_person_name
    industry_person.name if industry_person
  end

  def industry_person_name=(name)
    self.industry_person = IndustryPerson.find_or_create_by_name(name) unless name.blank?
  end
end
