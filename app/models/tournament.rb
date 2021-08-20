class Tournament < ApplicationRecord
	has_and_belongs_to_many :teams
	has_many :assessments
end
