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
		@user = User.find(params[:user_id])
		respond_to do |format|
			format.js
		end
	end

	def following #user's follow list
		@user = User.find(params[:user_id])
		respond_to do |format|
			format.js
		end
	end

	def my_watches
		@user = User.find(params[:user_id])
		respond_to do |format|
			format.js
		end
	end

	def my_joins
		@user = User.find(params[:user_id])
		respond_to do |format|
			format.js
		end
	end

	def friends
		@friend_ids = current_user.contact_ids
		@friends = current_user.contacts.find(@friend_ids)
		render :json => @friends.to_json
	end

	def find_friends
		puts "find_friends"
		render nothing:true
	end

	##
	# Show activity of users current_user follows
	def status_feed
		# get following list
		@user = User.find(current_user.id)
		following_ids = []
		if @user.followees_count_by_type("user") != 0
			following_list = @user.followees_by_type("user")
			following_list.each do |following|
     			following_ids.push(following._id)
     		end
     		# want: Micropost.desc.find(user:following_ids)
			@microposts = Micropost.in(user:following_ids).limit(30)
			# p following_ids
			# @microposts.each do |post|
			# 	puts post.content
			# end
		end
		render 'users/feed'
	end
end


