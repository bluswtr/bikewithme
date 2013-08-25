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
		#render json: @user.all_followers
		respond_to do |format|
			format.html
			format.js
		end
	end

	def following #user's follow list
		@user = User.find(params[:user_id])
		#render json: @user.all_followees
		#render layout: "follow"
		respond_to do |format|
			format.html
			format.js
		end
	end

end