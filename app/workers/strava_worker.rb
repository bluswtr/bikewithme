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
		activities_hash.each do |activity|
			begin
				# get details on the current activity ie: polyline
				stream = 'activities/' + activity['id'].to_s + '/streams/latlng?resolution=medium&access_token='
				url = strava_url+stream+token
				p url
				response = URI.parse(url).read
				activity_hash = JSON.parse response
				
				# save into user's profile
				activity_hash.each do |polyline|
					# only except json that might be activities... ie: with no error messages...
					if polyline["type"] == "latlng"
						p activity['name']
						Event.create_stream(activity,user,polyline)
					end
				end

			# handle HTTP exceptions
			rescue OpenURI::HTTPError => ex
				puts "HTTPError"
			end
		end

		friends = "athlete/friends?access_token="
		url = strava_url+friends+token
		response = URI.parse(url).read
		friendlist_hash = JSON.parse response
		friendlist_hash.each do |friend|
			Contact.create_strava_contact(friend,user)
		end

		user.update_attribute(:update_strava_objects, false)
	end

	# def create_streams(token,db_uid)
	# 	activities = "athlete/activities?access_token="
	# 	activities_hash = strava_api(activities,token)
	# 	activities_hash['athlete'].each do |activity|
	# 		Event.create_stream(activity)
	# 	end
	# end

	# def create_friends(token,db_uid)
	# 	friends = "athlete/friends?access_token="
	# 	friendlist_hash = strava_api(friends,token)
	# 	friendlist_hash.each do |contact|
	# 		Contact.create_strava_contact(friend)
	# 	end
	# end
	
	##
	# Update User Objects
	def update_user_objects(token,db_uid)
		update_streams(token,db_uid)
		update_friends(token,db_uid)
	end

	def update_streams(token,db_uid)
	end

	def update_friends(token,db_uid)
	end
end