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
		render nothing: true
	end

end