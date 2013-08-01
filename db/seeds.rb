# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
# Environment variables (ENV['...']) are set in the file config/application.yml.
# See http://railsapps.github.io/rails-environment-variables.html
puts 'DEFAULT USERS'
User.delete_all
user = User.create! :name => ENV['ADMIN_NAME'].dup, :email => ENV['ADMIN_EMAIL'].dup, :password => ENV['ADMIN_PASSWORD'].dup, :password_confirmation => ENV['ADMIN_PASSWORD'].dup
puts 'user: ' << user.name

# BicycleRideDescriptor.delete_all
# open("/Users/bluswtr/Documents/01_Programming/Apps/rails3-mongoid-devise/db/bicycle_ride_descriptors.txt") do |descriptors|
# 	descriptors.read.each_line() do |descriptor|
# 		id,selector,name = descriptor.chomp.split(" ")
# 		puts id + ", " + selector + ", " + name
# 		BicycleRideDescriptor.create(_id: id, selector: selector, name: name)
# 	end
# end

Event.delete_all
open("/Users/bluswtr/Documents/01_Programming/Apps/bikewithme/db/events.txt") do |some_events|
	some_events.read.each_line() do |an_event|
		title,latitude,longitude,description,activity,pace,terrain,distance,road_type = an_event.chomp.split("@")
		user.events << Event.create(  title:title,
									  description:description,
									  activity:activity,
									  meeting_point:[longitude.to_f,latitude.to_f],
									  bicycle_ride:{pace:pace,
									  				terrain:terrain,
									  				distance:distance,
									  				road_type:road_type}
								)

	end
end