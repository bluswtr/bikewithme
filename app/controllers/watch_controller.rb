

class WatchController < ApplicationController
	before_filter :authenticate_user!

	def create
		@event_watched = Event.find(params[:event_id])
		current_user.follow(@event_watched)
		respond_to do |format|
			format.js { render :partial => "events/event_watched" }
		end
	end

	def destroy
		@event_watched = Event.find(params[:event_id])
		current_user.unfollow(@event_watched)
		respond_to do |format|
			format.js { render :partial => "events/event_unwatched" }
		end
	end 
end