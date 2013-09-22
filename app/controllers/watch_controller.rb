

class WatchController < ApplicationController	
	def update
		@event_watched = Event.find(params[:event_id])
		current_user.follow(@event_watched)
		# respond_to do |format|
		# 	format.js { render :partial => "event_watched" }
		# end
		render nothing: true
	end 
end