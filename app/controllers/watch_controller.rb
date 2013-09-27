

class WatchController < ApplicationController
	before_filter :authenticate_user!
	# def update
	# 	@event_watched = Event.find(params[:event_id])
	# 	current_user.follow(@event_watched)
	# 	# respond_to do |format|
	# 	# 	format.js { render :partial => "event_watched" }
	# 	# end
	# 	render nothing: true
	# end 

	def create
		@event_watched = Event.find(params[:event_id])
		current_user.follow(@event_watched)
		# respond_to do |format|
		# 	format.js { render :partial => "event_watched" }
		# end
		render nothing: true
	end

	def destroy
		@event_watched = Event.find(params[:event_id])
		current_user.unfollow(@event_watched)
		# respond_to do |format|
		# 	format.js { render :partial => "event_watched" }
		# end
		render nothing: true
	end 
end