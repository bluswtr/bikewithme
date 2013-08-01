class EventsController < ApplicationController
	before_filter :authenticate_user!, :only => [:new,:create]
	def new
		@event = Event.new
		#@event.meeting_point = Point.new(0,0)
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
								  activity:params["event"]["activity"],
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

		nearest_events = Array.new
		puts "begin"
		Event.geo_near([params["lng"].to_f,params["lat"].to_f]).each do |event|
			p event.meeting_point
			nearest_events.push(event)
		end
		puts "end"
		render :json => nearest_events.to_json
	end

end