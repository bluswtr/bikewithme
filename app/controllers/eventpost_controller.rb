
class EventpostController < ApplicationController
	before_filter :authenticate_user!

	def index
		# list strava rides, if empty redirect to add custom ride
		# @events = current_user.events.where(:publishing_status => 'false').order_by(:updated_at.desc).page params[:page]
		# if @events == 'false'
		@events = current_user.events.from_strava.order_by(:updated_at.desc)
		if @events == nil
			redirect_to new_event_path(), notice: "Looks like there weren\'t any rides in the past. Let\'s create one from scratch!"
		else
			@events = current_user.events.from_strava.order_by(:updated_at.desc).page params[:page]
		end
	end

	def edit
		bikewithme_log("EventpostController#edit #{params}")
		event = Event.find(params[:id])
		@event = event.clone(current_user)
		@session = lnglat
	end

	def update
		bikewithme_log("EventpostController#update")
		event = Event.find(params[:clone_id])
		if params[:cancel]
			event.delete
		 	redirect_to eventpost_index_path
		else
			event.meeting_point = [params[:longitude].to_f,params[:latitude].to_f]
			event.address = params[:address]
			event.activity_id = params[:activity_id]
			event = mongo_save(event)

			if !event.valid?
				bikewithme_log("#{event.id} #{event.errors.messages}")
				render "public/404", :formats => [:html], status: :not_found
	    	else
			 	redirect_to eventpost_details_path(event.id)
			end
		end
	end

	def details
		@event = Event.find(params[:eventpost_id])
		@descriptors = Descriptor.format_for_option_tag(1)
	end

	def update_details
		bikewithme_log("EventpostController#update_details #{params}")
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

		event.update_time(params['date'],params['time'])

		privacy = 'false'
		if params[:event][:is_private] == '1'
			privacy = 'true'
		end
		event.is_private = privacy
		event = mongo_save(event)

		if !event.valid?
			bikewithme_log("#{event.id} #{event.errors.messages}")
			render "public/404", :formats => [:html], status: :not_found
	    else
			redirect_to event_url(event.id), notice: flash_text
	    end
	end
end