class UsersController < ApplicationController
	before_filter :authenticate_user!

	def index
		@users = User.all
	end

	def show
		@user = User.find(params[:id])
	end

	def followers
		@user = User.find(params[:user_id])
		# p @user.all_followees 
		# p @user.all_followers

		render json: @user.all_followers
	end

	def following #user's follow list
		@user = User.find(params[:user_id])
		render json: @user.all_followees
		#render layout: "follow"
	end

	def follow
		render nothing: true
	end

end