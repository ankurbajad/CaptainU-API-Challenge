user_1 = User.create(full_name: "Ankur Bajad", email: "ankur01@mailinator.com", password: "12345678", password_confirmation: "12345678" )

tournament_1 = Tournament.create(name: "ATP Tour",city: "Patna",state: "Bihar",start_date: "10/11/2000")
tournament_2 = Tournament.create(name: "WTA Tour",city: "Birmingham",state: "Alabama",start_date: "03/05/2001" )
tournament_3 = Tournament.create(name: "ATP Challenger Tour tournaments
",city: "Los Angeles",state: "California",start_date: "07/07/2004" )
tournament_4 = Tournament.create(name: "Exhibition tournaments",city: "Indore",state: "Madhya Pradesh",start_date: "10/11/2006" )
tournament_5 = Tournament.create(name: "Past events",city: "Bhopal",state: "Madhya Pradesh",start_date: "10/08/2008" )


team_1 = Team.create(name: "Cricket Team", age_group: "22-30" ,coach: "Ravi Shastri")
team_2 = Team.create(name: "Football Team", age_group: "22-30" ,coach: "Igor Stimac")
team_3 = Team.create(name: "Hockey Team", age_group: "22-30" ,coach: "Gharam Reid")
team_4 = Team.create(name: "Basketball Team", age_group: "22-30" ,coach: "Veselin Matić")
team_5 = Team.create(name: "Khokho Team", age_group: "22-30" ,coach: "Graham Reid
")
puts "Teams created"

crick_player_1 = team_1.players.create(first_name: "Shikhar", last_name: "Dhawan", height: 5.8  , weight:71 , birthday:"December 5, 1985" ,graduation_year: 2006 ,position: "Batsman" , recruit: "yes")
team_1.players.create(first_name: "Ravindra", last_name: "Jadeja", height: 5.7  , weight:60 , birthday:"December 6, 1988" ,graduation_year: 2009 ,position: "All Rounder" , recruit: "yes")
team_1.players.create(first_name: "Rohit" ,last_name: "Sharma", height: 5.8  , weight:72 , birthday:"April 30, 1987" ,graduation_year: 2009 ,position: "Batsman" , recruit: "yes")
team_1.players.create(first_name: "Cheteshwar", last_name: "Pujara", height: 5.1  , weight:71 , birthday:"January 25, 1988" ,graduation_year: 2009 ,position: "Batsman" , recruit: "yes")
team_1.players.create(first_name: "Ishant" ,last_name: "Sharma", height: 6.3  , weight:84 , birthday:"September 2, 1988" ,graduation_year: 2009 ,position: "Bowler" , recruit: "yes")
team_1.players.create(first_name: "Ajinkya", last_name: "Rahane", height: 5.6  , weight:60 , birthday:"June 6, 1988" ,graduation_year: 2009 ,position: "Batsman" , recruit: "yes")
team_1.players.create(first_name: "Virat", last_name: "Kohli", height: 5.9  , weight:60 , birthday:"November 5, 1988" ,graduation_year: 2009 ,position: "Batsman" , recruit: "yes")
team_1.players.create(first_name: "Bhuvneshwar", last_name: "Kumar", height: 5.7  , weight:70 , birthday:"February 5, 1990" ,graduation_year: 2012 ,position: "Bowler" , recruit: "yes")
team_1.players.create(first_name: "Wriddhiman", last_name: "Saha", height: 5.7  , weight:62 , birthday:"October 24, 1984" ,graduation_year: 2006 ,position: "Wicket Keeper" , recruit: "yes")
team_1.players.create(first_name: "Ravichandran", last_name: "Ashwin", height: 5.8  , weight:72 , birthday:"September 17, 1986" ,graduation_year: 2009 ,position: "All Rounder" , recruit: "yes")

hockey_player_1 = team_3.players.create(first_name: "Manpreet", last_name: "Singh", height: 5.7, weight: 69, birthday: "26 June 1992", graduation_year: 2012, position: "Midfielder", recruit: "yes" )
team_3.players.create(first_name: "Harmanpreet", last_name: "Singh", height: 5.9, weight: 70, birthday: "6 January 1996", graduation_year: 2016, position: "Forward", recruit: "yes")
team_3.players.create(first_name: "Varun", last_name: "Kumar", height: 5.8, weight: 65, birthday: "25 July 1995", graduation_year: 2015, position: "Defender", recruit: "yes")
team_3.players.create(first_name: "Surender", last_name: "Kumar", height: 5.10, weight: 77, birthday: "23 November 1993", graduation_year: 2013, position: "Defender",recruit: "yes")
team_3.players.create(first_name: "Gurinder", last_name: "Singh", height: 5.8, weight: 67, birthday: "1 January 1995", graduation_year: 2015, position: "Forward", recruit: "yes")
team_3.players.create(first_name: "Amit", last_name: "Rohidas", height: 5.9, weight: 61, birthday: "10 May 1993", graduation_year: 2013, position: "Defender", recruit: "yes")
team_3.players.create(first_name: "Somwarpet", last_name: "Sunil", height: 5.9, weight: 68,birthday: "6 May 1989", graduation_year: 2009, position: "Halfback", recruit: "yes")

team_3.players.create(first_name: "Hardik", last_name: "Singh", height: 5.9, weight: 55, birthday: "23 September 1998", graduation_year: 2018, position: "Midfielder", recruit: "yes" )
team_3.players.create(first_name: "Simranjeet", last_name: "Singh", height: 5.7, weight: 60, birthday: "27 December 1996", graduation_year: 2016, position: "Midfielder", recruit: "yes")
team_3.players.create(first_name: "Ramandeep", last_name: "Singh", height: 5.10, weight: 76, birthday: "1 April 1993", graduation_year: 2013, position: "Forward",recruit: "yes")


puts "Players created"


tournament_1.teams << team_1
tournament_1.teams << team_2
tournament_1.teams << team_3

tournament_2.teams << team_4
tournament_2.teams << team_5

puts "Teams added in tournaments"

#Add Assesement
Assessment.new(rating: 10,user_id: user_1.id, tournament_id: tournament_1.id, player_id: crick_player_1.id ).save!
Assessment.new(rating: 10,user_id: user_1.id, tournament_id: tournament_1.id, player_id: hockey_player_1.id ).save!


puts "Assessment created"