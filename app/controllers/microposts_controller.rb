class MicropostsController < ApplicationController
	before_filter :authenticate_user!

	def create
		micropost = Micropost.create_status(current_user,params)
	end

	def delete
		Micropost.where(params['micropost_id']).delete
	end

	##
	# Show current user's activity
	def show
		@microposts = current_user.microposts
		p @microposts
		render 'users/feed'
	end

end
