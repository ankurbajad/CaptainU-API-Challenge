class Player < ApplicationRecord
	belongs_to :team
	has_one :assessment
end
