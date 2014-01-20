
class EventsearchController < ApplicationController
	def show
	end

	def index
	    nearest_events = Array.new
	    options = Array.new
	    rows_to_display = Event.count
		nearest_event_data = Event.nearest("public",lnglat,nil)
		i = 0

		unless no_results.call(nearest_event_data)
			nearest_event_data.each do |event|
				temp = Array.new
				temp = User.find(event.user_id)
				nearest_events[i] = {user:{name:temp.name,userid:temp._id},event:event}
				i+=1
				if i == rows_to_display
					break
				end
			end
		end
		@event_data = Kaminari.paginate_array(nearest_events).page(params[:page]).per(10)
		@options = Descriptor.get_options
	end
end