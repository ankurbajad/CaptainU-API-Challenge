class Api::V1::TournamentsController < ApiController

	def index
		@tournaments = Tournament.all
	end
end
