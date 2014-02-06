
class EventpostController < ApplicationController
	before_filter :authenticate_user!
	def create
	# post new ride as unpublished and switch back to show ride w/ selected ride populated
	@event = Event.init(current_user,params['event']['title'],params['longitude'],params['latitude'],params['event']['description'],params['bicycle_ride']['distance'])
		redirect_to eventpost_path(@event.id)
	end

	def index
		# lists events owned by current_user
	end

	def edit
		@event = Event.find(params[:id])
		@descriptors = Descriptor.format_for_option_tag(1)
	end

	def show
		@event = Event.find(params[:id])
	end

	def update
		event = Event.find(params[:id])
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