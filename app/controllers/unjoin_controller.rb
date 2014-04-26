class UnjoinController < ApplicationController
	before_filter :authenticate_user!

	def create
		@event_joined = Event.find(params[:event_id])
		current_user.unjoin(@event_joined)

		content = "#{current_user.name} left <a href=#{event_url(params[:event_id])}>#{@event_joined.title}</a>"
		Micropost.create(current_user,content)

		respond_to do |format|
			format.js { render :partial => "events/event_unjoined" }
		end
	end
end