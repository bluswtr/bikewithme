

class UnwatchController < ApplicationController
	before_filter :authenticate_user!

	def create
		# mark as unwatched 
		@event_watched = Event.find(params[:event_id])
		current_user.unfollow(@event_watched)

		# announce activity
		content = "#{current_user.name} unwatched <a href=#{event_url(params[:event_id])}>#{@event_watched.title}</a>"
		Micropost.create(current_user,content)

		# serve a UI response
		respond_to do |format|
			format.js { render :partial => "events/event_unwatched" }
		end
	end 
end