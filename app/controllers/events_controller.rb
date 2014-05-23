
class EventsController < ApplicationController
	before_filter :authenticate_user!, :only => [:new,:create,:watch,:join,:more_info,:index,:delete,:edit,:update]
	def new
		@event = Event.new
		@descriptors = Descriptor.format_for_option_tag(1)
		@session = lnglat
	end

	def index
		# lists events owned by current_user
		@events = current_user.events.published.future_events.order_by(:updated_at.desc).page params[:page]
	end

	def past_rides
		# display rides, beginning with the rides that occurred before this moment
		@events = current_user.events.published.past_events.page params[:page]
	end

	def active_rides
		@events = current_user.events.published.future_events.page params[:page]
	end

	def drafts
		@events = current_user.events.drafts.page params[:page]
	end

	def watchlist
		@events = current_user.events.drafts.page params[:page]
	end

	def edit
		@event = Event.find(params[:id])
		@descriptors = Descriptor.format_for_option_tag(1)
		@session = lnglat
	end

	def update
		if params[:cancel]
		 	redirect_to events_path
		else
			event = Event.update_default(params)
			redirect_to event_url(event), notice: "Event Updated"
		end
	end

	def create
		@event = Event.create_custom(current_user,params)
		redirect_to new_event_invite_url(@event.id), notice: "Event Saved"
	end

	def destroy
		event = Event.find(params[:id])
		event.delete
		redirect_to action: 'index', status: 303
	end

	def landing
		# routes to views/events/landing.html.erb
	end

	def show
		@event = Event.find(params[:id])
		@watched = false
		@joined = false
		@session = lnglat

		if(user_signed_in? && current_user.follower_of?(@event))
			@watched = true
		end
		if(user_signed_in? && current_user.joiner_of?(@event))
			@joined = true
		end
		@descriptors = Descriptor.format_for_option_tag(1)
	end

	def home
		@ip = request.remote_ip
	end

	def more_info
		@event = Event.find(params[:event_id])
		if user_signed_in?
			@watched = current_user.follower_of?(@event)
			@joined = current_user.joiner_of?(@event)
			respond_to do |format|
				format.js { render :partial => "event_show_popup" }
			end
		else
			# perhaps prompt the user to signup?
			render nothing: true
		end
	end

	def join
		@event_joined = Event.find(params[:event_id])
		current_user.join(@event_joined)
		respond_to do |format|
			format.js { render :partial => "event_joined" }
		end
	end

	def next_seven_days
		time = Date.today
		seven_days = time + 7
		nearest_events = Hash.new
		distance = 50.fdiv(111.12)

		Event.where(:event_date.gt => time, :event_date.lt => seven_days).desc.limit(10).geo_near([params["lng"].to_f,params["lat"].to_f]).max_distance(distance).each do |event|
			#p event.meeting_point
			#nearest_events.push(event)
			temp = Array.new
			temp = User.find(event.user_id)
			nearest_events[$i] = { user: temp, event: event }
			$i += 1
		end

		# if count is 0, inform user w/ an alert component in bootstrap
		# else remove current markers and display events
		if nearest_events.count == 0
			respond_to do |format|
				format.js { render :partial => "event_alert" }
			end
		else 
			respond_to do |format|
				format.js { render :partial => "next_seven_days" }
			end
		end
	end

	def nearest_all
		puts "all"
		render nothing: true
	end
	
	# def compose_invite
	# 	respond_to do |format|
	# 		format.html
	# 	end
	# end

	def invite
		UserMailer.invite(params,current_user).deliver
		render nothing: true
	end

	def nearest_friends
		# TODO don't forget to take care of 0 or nil case
		if(current_user.followers_count_by_type("user")==0)
			respond_to do |format|
				format.js { render :partial => "modal_no_friends_yet" }
			end
		else
			event_data = Event.nearest("friends",lnglat,current_user)
			render :json => event_data.to_json
		end
	end

	def nearest_json
	    event_data = Hash.new
	    nearest_events = Hash.new
	    options = Array.new
	    rows_to_display = 15
		save_latlng(params["lat"],params["lng"])
    	no_results = ->(obj){ if obj == 0 || obj == nil then return true end }
		# takes params[:filter] (friends, public, private), params[:lat], session[:lng], params[:distance]
		nearest_event_data = Event.nearest("public",lnglat,nil)
	    unless no_results.call(nearest_event_data)
			i = 0
			nearest_event_data.each do |event|
				temp = Array.new
				# return name, userid, 
				temp = User.find(event.user_id)
				nearest_events[i] = {user:{name:temp.name,userid:temp._id},event:event}
				i+=1
				# Number of rows to display
				if i == rows_to_display
					break
				end
			end

			options = Descriptor.get_options
			event_data["nearest_events"] = nearest_events
			event_data["options"] = options
		end
		render :json => event_data.to_json
	end

	def save_geolocation
		save_latlng(params["lat"],params["lng"])
		render nothing:true
	end


	# def save_geolocation_to_object
	# 	event = Event.find(params[:id])
	# 	Event.update_coordinates(event,params[:lat],params[:lng])
	# end

	# def save_address_to_object
	# 	Event.update_address(params[:id],params["address"])
	# end

	def geolocation_search
		Event.find
		address = Event.geocoder_search(params[:ip_latlng_address])
		unless no_results.call(address)
			render :json => address[0].formatted_address.to_json
		else
			render nothing: true
		end
	end
end