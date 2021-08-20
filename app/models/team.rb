class Team < ApplicationRecord
	has_and_belongs_to_many :tournaments
	has_many :players
	has_one :assessments
end
