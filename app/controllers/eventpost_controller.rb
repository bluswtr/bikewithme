
class EventpostController < ApplicationController
	before_filter :authenticate_user!
	def create
	# post new ride as unpublished and switch back to show ride w/ selected ride populated
	# @event = Event.init(current_user,params['event']['title'],params['longitude'],params['latitude'],params['event']['description'],params['bicycle_ride']['distance'])
    	@event = current_user.events.create(meeting_point:[params['longitude'].to_f,params['latitude'].to_f])
    	p @event
		redirect_to eventpost_edit_details_path(@event.id)
	end

	def index
		# lists events owned by current_user
	end

	def edit
		@event = Event.find(params[:id])
	end

	def edit_details
		@event = Event.find(params[:eventpost_id])
		@descriptors = Descriptor.format_for_option_tag(1)
	end

	def show
		#@event = Event.find(params[:id])
	end

	def update
		event = Event.find(params[:id])
		if params[:publish]
			puts 'published'
			Event.update_publishing_status(event,'published')
		elsif params[:draft]
			puts 'draft'
			Event.update_publishing_status(event,'draft')
		end

		year,month,day = params['date'].chomp.split('-')
		hour,minute = params['time'].chomp.split(':')
		Event.update_time(event,year,month,day,hour,minute)

		is_private = 'false'
		if params[:event][:is_private] == '1' 
			is_private = 'true'
		end
		event = Event.update_is_private(event,is_private)
		redirect_to event_url(event.id), notice: 'Event Saved'
	end


end