class EventsController < ApplicationController
	before_filter :authenticate_user!, :only => [:new,:create]
	def new
		@event = Event.new
		@descriptors = Descriptor.format_for_option_tag(1)
	end

	def index
		# request geolocation, ?
		#@events = Event.geonear({meeting_point})
		# pass in meeting points in erb page
	end

	def show
		# if params:id exists show event/:id 
		# otherwise show nearest
	end

	def test
		render nothing: true
	end

	def create
		##
		# About mongodb geospatial insertions: mongodb will take an array with two 
		# values, convert the first into longitude and the next into latitude.

		##
		# Create if doesn't exist
		longitude = params["longitude"].to_f
		latitude = params["latitude"].to_f
		date = Time.utc(params["event_date"]["year"],params["event_date"]["month"],params["event_date"]["day"],
						params["event_date"]["hour"],params["event_date"]["minute"])
		date.iso8601(3)
		current_user.events.create( title:params["event"]["title"],
								  meeting_point:[longitude,latitude],
								  event_date:date,
								  description:params["event"]["description"],
								  activity_id:params["event"]["activity_id"],
								  bicycle_ride:{pace:params["bicycle_ride"]["pace"],
								  				terrain:params["bicycle_ride"]["terrain"],
								  				distance:params["bicycle_ride"]["distance"],
								  				road_type:params["bicycle_ride"]["road_type"]}
								)
		# get status after create

		# redirect to post

		# for now
		#render nothing: true

		# later render listings/auto-update?
	end

	def nearest

		#where(:event_date.gt => Time.parse(Date.today))
		# query for the user and add to the hash somehow....
		event_data = Hash.new
		options = Array.new
		nearest_events = Hash.new
		$i = 0
		Event.desc.limit(10).geo_near([params["lng"].to_f,params["lat"].to_f]).max_distance(50).each do |event|
			p event.meeting_point
			#nearest_events.push(event)
			temp = Array.new
			temp = User.find(event.user_id)
			nearest_events[$i] = {user:temp, event: event}
			$i+=1
		end
		options = Descriptor.get_options
		event_data["nearest_events"] = nearest_events
		event_data["options"] = options

		#p nearest_events.to_json
		render :json => event_data.to_json
	end

end