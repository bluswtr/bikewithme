
class EventpostController < ApplicationController
	before_filter :authenticate_user!

	def index
		# lists events owned by current_user
		@events = current_user.events.where(:publishing_status => 'false').order_by(:updated_at.desc).page params[:page]
	end

	def edit
		temp = Event.find(params[:id])
		event_copy = temp.clone
		event_copy.unset(:strava_activity_id)
		event_copy.update_publishing_status('draft')
		event_copy.save
		@event = Event.find(event_copy._id)
	end

	def update
		if params[:cancel]
		 	redirect_to eventpost_index_path
		else
			event = Event.find(params[:clone_id])
			event.meeting_point = [params[:longitude].to_f,params[:latitude].to_f]
			event.address = params[:address]
			event.activity_id = params[:activity_id]
			event.bicycle_ride.polyline = params[:polyline]
			event.bicycle_ride.altitude = params[:altitude]
			event = mongo_save(event)
		 	redirect_to eventpost_details_path(event.id)
		end
	end

	def details
		@event = Event.find(params[:eventpost_id])
		@descriptors = Descriptor.format_for_option_tag(1)
	end

	def show
		#@event = Event.find(params[:id])
	end

	def update_details
		event = Event.find(params[:eventpost_id])
		event.title = params[:event][:title]
		event.description = params[:event][:description]

		event.bicycle_ride.distance = params[:bicycle_ride][:distance]
		event.bicycle_ride.pace = params[:bicycle_ride][:pace]
		event.bicycle_ride.terrain = params[:bicycle_ride][:terrain]
		event.bicycle_ride.road_type = params[:bicycle_ride][:road_type]

		flash_text = ''
		if params[:publish]
			flash_text = 'Event Published'
			event.publishing_status = 'published'
		elsif params[:draft]
			flash_text = 'Draft Saved'
			event.publishing_status = 'draft'
		end

		year,month,day = params['date'].chomp.split('-')
		hour,minute = params['time'].chomp.split(':')
		event.update_time(year,month,day,hour,minute)

		privacy = 'false'
		if params[:event][:is_private] == '1'
			privacy = 'true'
		end
		event.is_private = privacy
		event = mongo_save(event)
		redirect_to event_url(event.id), notice: flash_text
	end


end