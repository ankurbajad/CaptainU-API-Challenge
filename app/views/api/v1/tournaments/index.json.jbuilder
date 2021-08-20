if @tournaments.present?
  json.tournaments do
    json.array! @tournaments.each do |tournament|
      json.name               tournament.name
      json.city               tournament.city
      json.state              tournament.state
      json.start_date         tournament.start_date
      if tournament.teams.present?
        json.teams        tournament.teams.each do |team|
          json.name               team.name
          json.age_group          team.age_group
          json.coach              team.coach
          if team.players.present?
            json.players team.players.each do | player |
              json.first_name               player.first_name
              json.last_name                player.last_name
              json.height                   player.height
              json.weight                   player.weight
              json.birthday                 player.birthday
              json.graduation_year          player.graduation_year
              json.position                 player.position
              json.recruit                  player.recruit
              if player.assessment.present?
                  json.assessment
                  json.rating               player.assessment.rating
                  json.assessment_type      player.assessment.assessment_type
                  json.tournament_name      Tournament.find(player.assessment.tournament_id).name
                  json.assesement_user      User.find(player.assessment.user_id).full_name
              else
                json.assessment []
                
              end
            end
          else
            json.players []
          end
        end
      else
        json.teams []
      end
    end
  end
else
  json.tournaments []
end
