class JoinController < ApplicationController
	before_filter :authenticate_user!
	def create
		@event_joined = Event.find(params[:event_id])
		current_user.join(@event_joined)
		# respond_to do |format|
		# 	format.js { render :partial => "event_joined" }
		# end
		render nothing: true
	end

	def destroy
		@event_joined = Event.find(params[:event_id])
		current_user.unjoin(@event_joined)
		# respond_to do |format|
		# 	format.js { render :partial => "event_joined" }
		# end
		render nothing: true
	end
end