class UsersController < ApplicationController
	before_filter :authenticate_user!

	def index
		@users = User.all
		@following = current_user.followees_by_type("user")
	end

	def show
		@user = User.find(params[:id])
	end

	def followers
		respond_to do |format|
			format.js
		end
	end

	def following #user's follow list
		respond_to do |format|
			format.js
		end
	end

	def my_watches
		respond_to do |format|
			format.js
		end
	end

	def my_joins
		respond_to do |format|
			format.js
		end
	end
end