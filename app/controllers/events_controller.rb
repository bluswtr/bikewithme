
class EventsController < ApplicationController
	before_filter :authenticate_user!,:only => [:new,:create,:more_info,:index,:delete,:edit,:update]
	def new
		event = Event.new(title:"Untitled #{local_time.strftime("%Y-%m-%d %l:%M %p")}",publishing_status:"draft")
		bikewithme_log("EventsController#new #{event.errors.messages}")
		if !event.valid?
			render "public/404", :formats => [:html], status: :not_found
		else
	    	event.bicycle_ride = BicycleRide.new
			@descriptors = Descriptor.format_for_option_tag(1)
			@session = lnglat
			event.save!
			current_user.events << event
			@event = event
		end
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
		elsif params[:destroy]
			event = Event.find(params[:id])
			event.delete
			redirect_to action: 'index', status: 303
		else
			event = Event.update_default(params)
			bikewithme_log("EventsController#update #{event.errors.messages}")
			if !event.valid?
				render "public/404", :formats => [:html], status: :not_found
	    	else
				# redirect_to event_url(event.id), notice: "Event Updated"
				redirect_to to_event_invite_index_url(:event_id => event.id), notice: "Event Saved"
			end
		end
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

	# def join
	# 	@event_joined = Event.find(params[:event_id])
	# 	current_user.join(@event_joined)
	# 	respond_to do |format|
	# 		format.js { render :partial => "event_joined" }
	# 	end
	# end

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

	def invite
		UserMailer.invite(params,current_user).deliver
		bikewithme_log("EventsController#invite: #{params}")
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
		if(params["lat"] == false && params["lng"] == false)
			save_latlng(false,false)
		else
			save_latlng(params["lat"],params["lng"])
		end
		render nothing:true
	end

	def save_timezone_offset
		save_utc_offset(params[:offset])
		render nothing:true
	end

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