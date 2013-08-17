class UnfollowController < ApplicationController	

	def update
		# in template check if already following 
		# create a button that corresponds to that state
		@user = User.find(params[:id])
		current_user.unfollow(@user)

		# send back http success
		# if @contact.followed? head :created else head :not_found end
		# head :created
		render nothing: true
	end 
end