class UsersController < ApplicationController
	before_filter :authenticate_user!

	def index
		@users = User.all
	end

	def show
		@user = User.find(params[:id])
	end

	def followers
		render nothing: true
	end

	def following
		render nothing: true
	end

	def follow
		# check if id exists yet
		#current_user.following << Contact.create(params[:id])
		render nothing: true
	end
end