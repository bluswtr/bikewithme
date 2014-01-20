class MicropostsController < ApplicationController
	before_filter :authenticate_user!

	def create
		micropost = Micropost.create_status(current_user,params)
	end

	def delete
		micropost = Micropost.find(params['micropost_id'])
		Micropost.delete(current_user,micropost)
	end

	##
	# Show current user's activity
	def show
		@microposts = current_user.microposts
		p @microposts
		render 'users/feed'
	end

end
