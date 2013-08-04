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
	end

	def create
		##
		# About mongodb geospatial insertions: mongodb will take an array with two 
		# values, convert the first into longitude and the next into latitude.

		##
		# Create if doesn't exist
		longitude = params["longitude"].to_f
		latitude = params["latitude"].to_f
		current_user.events << Event.create( title:params["event"]["title"],
								  meeting_point:[longitude,latitude],
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
		event_data = Hash.new
		options = Array.new
		nearest_events = Array.new
		Event.geo_near([params["lng"].to_f,params["lat"].to_f]).each do |event|
			p event.meeting_point
			nearest_events.push(event)
		end
		options = Descriptor.get_options
		event_data["nearest_events"] = nearest_events
		event_data["options"] = options

		# nearest_events = Hash.new(0);
		# $i=0
		# Event.geo_near([params["lng"].to_f,params["lat"].to_f]).each do |event|
		# 	nearest_events[['events',$i]] = event
		# 	$i+=1
		# end
		# nearest_events[['bike_descriptors','pace']] = BicycleRide::PACE
		#p nearest_events.to_json
		#render nothing: true
		render :json => event_data.to_json
		#render :json => nearest_events.to_json
	end

end