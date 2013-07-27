class EventsController < ApplicationController
	before_filter :authenticate_user!, :only => [:new,:create]
	def new
		@event = Event.new
		@event.meeting_point = Point.new(0,0)
	end

	def show
		#@event = Event.geonear({meeting_point})
	end

	def create
		# get handle to current user
		current_user.events << Event.create( title:params["event"]["title"],
								  meeting_point:params["event"]["meeting_point"],
								  description:params["event"]["description"],
								  activity:params["event"]["activity"],
								  bicycle_ride:{pace:params["bicycle_ride"]["pace"],
								  				terrain:params["bicycle_ride"]["terrain"],
								  				distance:params["bicycle_ride"]["distance"],
								  				road_type:params["bicycle_ride"]["road_type"]}
								)

	end

end