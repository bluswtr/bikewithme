##
# all users can do a search but you have to be logged in to know if you are watching... 
# 
class EventsearchController < ApplicationController
	def index
		@session_lng_lat = lnglat
		if @session_lng_lat[0] && @session_lng_lat[1]
			nearest_events = Array.new
		    options = Array.new
		    rows_to_display = Event.count
			nearest_event_data = Event.published.nearest("public",lnglat,nil)
			i = 0
			@count = 0

			unless no_results.call(nearest_event_data)
				nearest_event_data.each do |event|

					temp = Array.new
					temp = User.find(event.user_id)
					watched = false
					joined = false

					if(user_signed_in? && current_user.follower_of?(event))
						watched = true
					end
					if(user_signed_in? && current_user.joiner_of?(event))
						joined = true
					end
					
					nearest_events[i] = {user:{name:temp.name,userid:temp._id},event:event,bicycle_ride:event.bicycle_ride,watched:watched,joined:joined}
					i+=1
					if i == rows_to_display
						break
					end
				end
			end
			@count = i
			@event_data = Kaminari.paginate_array(nearest_events).page(params[:page]).per(10)
			@descriptors = Descriptor.get_options
		end

	puts "session_location: #{@session_lng_lat}"
	end
end