class WatchController < ApplicationController
	before_filter :authenticate_user!

	def create
		# mark as watched
		@event_watched = Event.find(params[:event_id])
		current_user.follow(@event_watched)

		# announce activity
		content = "#{current_user.name} is watching <a href=#{event_url(params[:event_id])}>#{@event_watched.title}</a>"
		Micropost.create(current_user,content)

		# Serve a UI response
		respond_to do |format|
			format.js { render :partial => "events/event_watched" }
		end
	end
end