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
		p @user.all_followees #user's follow list
		p @user.all_followers
		# User.followers_of(@contact).each do |follower| 
		# 	puts "hello"
		# 	p follower
		# end



		puts "hi"

		render nothing: true
	end

	def following
		render nothing: true
	end

	def follow
		render nothing: true
	end

end