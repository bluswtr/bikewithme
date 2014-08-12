class StravaWorker 
	include Sidekiq::Worker
	require 'open-uri'

	def perform(token,db_uid)
		# construct url to access streams
		strava_url = "https://www.strava.com/api/v3/"
		activities = "athlete/activities?access_token="
		url = strava_url+activities+token
		p url

		# get full list of user activities
	    user = User.find(db_uid)
		response = URI.parse(url).read
		activities_hash = JSON.parse response
		altitude = Hash.new

		activities_hash.each do |activity|
			begin
				# get details on the current activity ie: polyline & altitude
				polyline_endpoint = 'activities/' + activity['id'].to_s + '/streams/latlng?resolution=medium&access_token='
				polyline_hash = JSON.parse URI.parse(strava_url+polyline_endpoint+token).read
				
				altitude_endpoint = 'activities/' + activity['id'].to_s + '/streams/altitude?resolution=medium&access_token='
				altitude_hash = JSON.parse URI.parse(strava_url+altitude_endpoint+token).read

				# save into user's profile
				polyline_hash.each do |polyline|
					# only except json that might be activities... ie: with no error messages...
					if polyline["type"] == "latlng"
						altitude_hash.each do |altitude_temp|
							if altitude_temp["type"] == "altitude"
								altitude = altitude_temp
							end
						end
						p activity['name']
						Event.create_stream(activity,user,polyline,altitude)
					end
				end

			# handle HTTP exceptions
			rescue OpenURI::HTTPError => ex
				puts "HTTPError"
			end
		end

		friends = "athlete/friends?access_token="
		friendlist_hash = JSON.parse URI.parse(strava_url+friends+token).read
		friendlist_hash.each do |friend|
			Contact.create_strava_contact(friend,user)
		end

		user.update_attribute(:update_strava_objects, false)
		user.save
	end
	
	##
	# Update User Objects
	def update_user_objects(token,db_uid)
		update_streams(token,db_uid)
		update_friends(token,db_uid)
	end
end