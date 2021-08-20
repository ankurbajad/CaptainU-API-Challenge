namespace :admin do
  desc "Create Time Intervals"
  task :create_time_intervals => :environment do
    TimeInterval.create([
      { name: '10 mins', value: 10 },
      { name: '15 mins', value: 15 },
      { name: '30 mins', value: 30 },
      { name: '45 mins', value: 45 },
      { name: '1 hr', value: 60 },
      { name: '4 hr', value: 240 },
    ])
  end

end
