class JoinController < ApplicationController
	before_filter :authenticate_user!
	
	def create
		# mark as joined
		@event_joined = Event.find(params[:event_id])
		current_user.join(@event_joined)

		# announce activity
		content = "#{current_user.name} joined <a href=#{event_url(params[:event_id])}>#{@event_joined.title}</a>"
		Micropost.create(current_user,content)

		# Serve a UI response
		respond_to do |format|
			format.js { render :partial => "events/event_joined" }
		end
	end
end